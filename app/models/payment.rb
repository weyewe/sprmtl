class Payment < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :invoices, :through => :invoice_payments 
  has_many :invoice_payments 
  belongs_to :customer 
  belongs_to :cash_account 
  
  validates_presence_of :creator_id , :amount_paid, :payment_method, :customer_id , :cash_account_id 
  
  validate :amount_paid_must_be_greater_than_zero
  validate :payment_method_and_cash_account_case_must_match
  
  def amount_paid_must_be_greater_than_zero
    if amount_paid.present? and amount_paid <= BigDecimal("0")
      errors.add(:amount_paid , "Jumlah yang dibayar harus lebih dari 0" )  
    end
  end
  
  def payment_method_and_cash_account_case_must_match
    if not cash_account.nil? and cash_account.case  == CASH_ACCOUNT_CASE[:bank][:value]
      if not self.bank_payment_method?
        errors.add(:payment_method , "Harus sesuai dengan tipe cash account" )  
      end
    elsif not cash_account.nil? and cash_account.case  == CASH_ACCOUNT_CASE[:cash][:value]
      if not self.cash_payment_method?
        errors.add(:payment_method , "Harus sesuai dengan tipe cash account" )  
      end
    end
  end
  
  def bank_payment_method?
    [
      PAYMENT_METHOD_CASE[:bank_transfer][:value],
      PAYMENT_METHOD_CASE[:giro][:value]
      ].include?( self.payment_method )
  end
  
  def cash_payment_method?
    [
      PAYMENT_METHOD_CASE[:cash][:value] 
      ].include?( self.payment_method )
  end
  
  def Payment.create_by_employee(employee, params)
    return nil if employee.nil? 
    
    new_object = Payment.new
    
    new_object.creator_id     = employee.id 
    new_object.customer_id    = params[:customer_id]
    new_object.amount_paid    = BigDecimal( params[:amount_paid] ) 
    new_object.payment_method = params[:payment_method]
    new_object.cash_account_id = params[:cash_account_id]

                                

    
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
    self.cash_account_id = params[:cash_account_id]

    self.save 
    
    return self 
  end
  
  def generate_code
    
    start_datetime = Date.today.at_beginning_of_month.to_datetime
    end_datetime = Date.today.next_month.at_beginning_of_month.to_datetime
    
    counter = SalesOrder.where{
      (self.created_at >= start_datetime)  & 
      (self.created_at < end_datetime )
    }.count
    
    header = ""
    if not self.is_confirmed?  
      header = "[pending]"
    end
    
    
    string = "#{header}PAY" + "/" + 
              self.created_at.year.to_s + '/' + 
              self.created_at.month.to_s + '/' + 
              counter.to_s
              
    self.code =  string 
    self.save 
  end
  
  def verify_amount_paid_equals_total_sum
    total_sum = BigDecimal("0")
    self.invoice_payments.each do |ip|
      total_sum += ip.amount_paid
    end
    
    if total_sum != self.amount_paid
      errors.add(:amount_paid , "Jumlah yang dibayar #{self.amount_paid} tidak sesuai dengan jumlah details (#{total_sum})" ) 
    end
  end
  
  def confirm(employee) 
    return nil if employee.nil? 
    return nil if self.invoice_payments.count == 0 
    return nil if self.is_confirmed == true  
    
    verify_amount_paid_equals_total_sum
    
    return self if self.errors.size != 0  
    
    # transaction block to confirm all the sales item  + sales order confirmation 
    ActiveRecord::Base.transaction do
      self.confirmer_id = employee.id 
      self.confirmed_at = DateTime.now 
      self.is_confirmed = true 
      self.save 
      self.invoice_payments.each do |ip|
        ip.confirm( employee )
      end
    end 
  end
  
  def delete( current_user ) 
    return nil if current_user.nil?
    return nil if self.is_confirmed? 
    
    self.invoice_payments.each do |ip|
      ip.delete( current_user ) 
    end
    
    self.destroy 
  end
  
  
  def Payment.selectable_payment_methods
    result = []
    PAYMENT_METHOD_CASE.each do |key, cac | 

      result << [ "#{cac[:name]}" , 
                      cac[:value] ]  
    end
    return result
  end
end
