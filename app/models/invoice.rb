class Invoice < ActiveRecord::Base
  # can only be printed if the invoice has due date 
  
  # attr_accessible :title, :body
  belongs_to :delivery 
  
  has_many :invoice_payments
  has_many :payments, :through => :invoice_payments 
  
  
  
  def Invoice.create_by_employee( employee, delivery) 
    return nil if employee.nil?
    return nil if delivery.nil? 
    return nil if delivery.is_confirmed == false 

    new_object = Invoice.new 
    new_object.creator_id   = employee.id 
    new_object.delivery_id  = delivery.id 

    if new_object.save
      new_object.generate_code
      new_object.update_amount_payable
    end

    return new_object 
  end
  
  def update_due_date( employee, due_date)
    return nil if employee.nil?
    
    
    if due_date.nil? 
      errors.add(:due_date , "Tanggal Jatuh Tempo harus diisi" )  
      return self 
    end
    
    self.due_date = due_date 
    self.save 
    return self 
    
  end
  
  
  def generate_code
    string = "INV" + "/" + 
              self.created_at.year.to_s + '/' + 
              self.created_at.month.to_s + '/' + 
              self.id.to_s
              
    self.code =  string 
    self.save 
  end
  
  def update_amount_payable
    
    total_amount = BigDecimal('0') 
    
    delivery.delivery_entries.each do |de|
      price = de.sales_item.price_per_piece
      quantity = 0 
      if delivery.is_confirmed?  and not delivery.is_finalized?
        quantity = de.quantity_sent
      elsif  delivery.is_confirmed?  and  delivery.is_finalized?
        quantity = de.quantity_confirmed
      end
      total_amount += price * quantity
    end
    
    self.amount_payable = total_amount
    self.save 
 
  end
  
  def update_paid_status(employee)
    self.reload
    if self.confirmed_pending_payment == BigDecimal("0")
      self.is_paid = true 
      self.paid_declarator_id = employee.id 
      self.paid_at = DateTime.now
      self.save 
    end
  end
  
  def pending_payment
    amount_payable - self.invoice_payments.sum("amount_paid") 
  end
  
  def confirmed_pending_payment
    amount_payable - self.invoice_payments.where(:is_confirmed => true ).sum("amount_paid") 
  end
  
  def has_pending_payment_confirmation?
    self.invoice_payments.where(:is_confirmed => false ).count != 0
  end
end
