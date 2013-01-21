class InvoicePayment < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :invoice 
  belongs_to :payment 
  
  validates_presence_of :invoice_id, :payment_id, :creator_id , :amount_paid
  validate :amount_paid_must_be_greater_than_zero_and_less_than_remaining_payable
  # validate :amount_paid_must_not_exceed_total_payable_in_the_invoice
  validate :uniqueness_of_invoice_payment 
  validate  :customer_ownership_to_invoice
  
  def amount_paid_must_be_greater_than_zero_and_less_than_remaining_payable
    invoice = self.invoice 
    if amount_paid.present? and 
        ( amount_paid <= BigDecimal("0") or 
          amount_paid > invoice.confirmed_pending_payment    )
      errors.add(:amount_paid , "Jumlah yang dibayar harus lebih dari 0 "+ 
                          "dan kurang dari #{invoice.confirmed_pending_payment}" )  
    end
  end
   
  def uniqueness_of_invoice_payment
    # puts "$$$$$$$$$$$$ Inside the uniqueness_of_invoice_payment\n"*5
    # puts "the parent_id : #{self.payment_id}"
    
    parent  = self.payment
    invoice_id_list  = parent.invoice_payments.map{|x| x.invoice_id }
    post_uniq_invoice_id_list = invoice_id_list.uniq 
   
    
    if not self.persisted? and post_uniq_invoice_id_list.include?( self.invoice_id)
        errors.add(:invoice_id , "Invoice #{self.invoice.code} sudah terdaftar di pembayaran ini" ) 
    elsif self.persisted? and invoice_id_list.length !=  post_uniq_invoice_id_list.length
        errors.add(:invoice_id , "Invoice #{self.invoice.code}  sudah terdaftar di pembayaran ini" ) 
    end
  end
  
  def customer_ownership_to_invoice
    parent = self.payment
    if parent.customer_id != self.invoice.delivery.customer_id 
      errors.add(:invoice_id , "Invoice #{self.invoice.code} tidak terdaftar di daftar penjualan." ) 
    end
  end
  
  
  def InvoicePayment.create_invoice_payment( employee ,payment,  params)
    return nil if employee.nil? 
    return nil if payment.nil? 
    
    
    new_object = InvoicePayment.new
    
    new_object.creator_id   = employee.id  
    new_object.payment_id  = payment.id 
    new_object.invoice_id  = params[:invoice_id]
    
    new_object.amount_paid = BigDecimal( params[:amount_paid]   )  
    
    if new_object.save 
      # new_object.generate_code 
    end
    
    return new_object
  end
  
  def update_invoice_payment( employee , payment ,  params ) 
    return nil if employee.nil?
    return nil if self.payment.is_confirmed? 
    
    self.creator_id  = employee.id 
    self.payment_id  = payment.id  
    self.invoice_id = params[:invoice_id]
    self.amount_paid = BigDecimal( params[:amount_paid]   )
    

    self.save 
    return self 
  end
  
  def delete( employee )
    return nil if employee.nil? 
    return nil if self.payment.is_confirmed? 
    
    self.destroy 
  end
  
  def confirm( employee ) 
    self.is_confirmed = true 
    self.confirmed_at = DateTime.now
    self.confirmer_id = employee.id
    self.save 
    
    # validate: 
    
    if self.errors.size !=  0   
      raise ActiveRecord::Rollback, "Call tech support!" 
    end
    
    self.invoice.update_paid_status(employee)
    # do some post payment update , such as updating the payment
    
  end
end
