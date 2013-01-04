class InvoicePayment < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :invoice 
  belongs_to :payment 
  
  validates_presence_of :invoice_id, :payment_id, :creator_id , :amount_paid
  validate :amount_paid_must_be_greater_than_zero
  validate :uniqueness_of_invoice_payment 
  validate  :customer_ownership_to_invoice
  
  def uniqueness_of_invoice_payment
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
  
  
  def InvoicePayment.create_invoice_payment( employee , params)
    return nil if employee.nil? 
    
    new_object = InvoicePayment.new
    new_object.creator_id = employee.id 
    
    
    new_object.invoice_id  = params[:invoice_id]
    new_object.payment_id  = params[:payment_id] 
    new_object.amount_paid = BigDecimal( params[:amount_paid]   )  
    
    if new_object.save 
      # new_object.generate_code 
    end
    
    return new_object
  end
  
  def update_invoice_payment( employee , params ) 
    return nil if employee.nil?
    return nil if self.payment.is_confirmed? 
    
    self.creator_id  = employee.id 
    self.invoice_id  = params[:invoice_id]
    self.payment_id  = params[:payment_id] 
    self.amount_paid = BigDecimal( params[:amount_paid]   )
    

    self.save 
    return self 
  end
  
  def delete( employee )
    return nil if employee.nil? 
    return nil if self.payment.is_confirmed? 
    
    self.destroy 
  end
end
