class Payment < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :invoices, :through => :invoice_payments 
  has_many :invoice_payments 
  
  validates_presence_of :creator_id , :amount_paid, :payment_method, :customer_id 
  
  validate :amount_paid_must_less_or_equal_than_zero
  
  def amount_paid_must_less_or_equal_than_zero
    if payment_method.present? and amount_paid <= BigDecimal("0")
      errors.add(:amount_paid , "Jumlah yang dibayar harus lebih dari 0" )  
    end
  end
  
  def Payment.create_by_employee(employee, params)
    return nil if employee.nil? 
    
    new_object = Payment.new
    new_object.creator_id = employee.id
    
    new_object.customer_id     = params[:customer_id]
    new_object.amount_paid    = BigDecimal( params[:amount_paid] ) 
    new_object.payment_method = params[:payment_method]
                                

    
    if new_object.save
      new_object.generate_code
    end
    
    return new_object
  end
  
  def update_by_employee( employee, params )  
    
    self.creator_id     = employee.id 
    self.customer_id    = params[:customer_id]
    self.amount_paid    = BigDecimal( params[:amount_paid] ) 
    self.payment_method = params[:payment_method]

    self.save 
    
    return self 
  end
  
  def generate_code
    string = "PAY" + "/" + 
              self.created_at.year.to_s + '/' + 
              self.created_at.month.to_s + '/' + 
              self.id.to_s
              
    self.code =  string 
    self.save 
  end
end
