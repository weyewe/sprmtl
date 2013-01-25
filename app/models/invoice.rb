class Invoice < ActiveRecord::Base
  # can only be printed if the invoice has due date 
  
  # attr_accessible :title, :body
  belongs_to :delivery 
  belongs_to :customer 
  
  has_many :invoice_payments
  has_many :payments, :through => :invoice_payments 
  validates_presence_of :customer_id 
  
  
  
  def Invoice.create_by_employee( employee, delivery) 
    return nil if employee.nil?
    return nil if delivery.nil? 
    return nil if delivery.is_confirmed == false 
    
    return nil if delivery.only_delivering_non_invoicable_goods? 

    new_object = Invoice.new 
    new_object.creator_id   = employee.id 
    new_object.delivery_id  = delivery.id 
    new_object.customer_id = delivery.customer_id 

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
    
    start_datetime = Date.today.at_beginning_of_month.to_datetime
    end_datetime = Date.today.next_month.at_beginning_of_month.to_datetime
    
    counter = self.class.where{
      (self.created_at >= start_datetime)  & 
      (self.created_at < end_datetime )
    }.count
    
    header = ""
    if not self.is_confirmed?  
      header = "[pending]"
    end
    
    string = "INV" + "/" + 
              self.created_at.year.to_s + '/' + 
              self.created_at.month.to_s + '/' + 
              counter.to_s 
              
    self.code =  string 
    self.save 
  end
  
  def update_amount_payable
    
    total_amount = BigDecimal('0') 
    
    delivery.delivery_entries.each do |de|
      total_amount +=  de.total_delivery_entry_price
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
 
=begin
  Delivery Printing
=end
  def printed_code
    self.code.gsub('/','-')
  end

  def calculated_vat
    BigDecimal("0")
  end

  def calculated_delivery_charges
    BigDecimal("0")
  end

  def calculated_sales_tax
    BigDecimal('0')
  end
end
