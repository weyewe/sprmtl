=begin
  Payment is used to handle $$ coming in from the member.
  
  $$ coming in can be: down payment or invoice payment
  
  User Case:
  1. ON creating sales order, has to give down payment  => auto create downpayment PAYMENT,
    has to be confirmed. The payment for this downpayment can come from 
  2. ON paying for invoice, there might be excess payment =>  the excess will go 
      to downpayment 
      
  # and how do we execute the payment? 
  
  # so, in creating payment, has to add 2 fields:
  1. new $$$
  2. use downpayment $$$ 
  
  How can we capture this downpayment in elegant manner? 
  1. in making sales order, specify the down payment. => boolean down_payment_required? 
  2. show in the sales item (factory) whether the downpayment has been paid. if not paid, maybe they 
    shouldn't do any production 
    
  3. In the payment, 3 fields: direct cash transfer, downpayment_usage , and extra downpayment 
=end

class Payment < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :invoices, :through => :invoice_payments 
  has_many :invoice_payments 
  belongs_to :customer 
  belongs_to :cash_account 
  has_many :downpayment_histories
  
  validates_presence_of :creator_id , :amount_paid, :payment_method, :customer_id , 
                        :downpayment_usage_amount , :downpayment_addition_amount
  
  validate :total_amount_paid_must_be_greater_than_zero
  validate :payment_method_and_cash_account_case_must_match
  validate :no_negative_payment 
  validate :cash_account_id_must_not_be_present_if_only_payment_using_downpayment
  validate :payment_method_must_be_matching_with_payment_scheme
  validate :validate_downpayment_usage_is_less_than_remaining_downpayment
  
  
  
  def total_amount_paid_must_be_greater_than_zero
    total_amount_paid = :downpayment_usage_amount , :downpayment_addition_amount , :amount_paid
    zero_value = BigDecimal("0")
    
    if amount_paid.present? and  (amount_paid == zero_value) and   
        downpayment_usage_amount.present? and (downpayment_usage_amount == zero_value) and   
        downpayment_addition_amount.present?  and (downpayment_addition_amount == zero_value)
      errors.add(:amount_paid , "Total Transaksi tidak boleh 0" )  
      errors.add(:downpayment_usage_amount , "Total Transaksi tidak boleh 0" )  
      errors.add(:downpayment_addition_amount , "Total Transaksi tidak boleh 0" )  
    end
  end
  
  def payment_method_and_cash_account_case_must_match
    
    if not is_only_downpayment_usage?
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
  end
  
  def no_negative_payment
    if amount_paid.present? and amount_paid < BigDecimal("0")
      errors.add(:amount_paid , "Tidak boleh negative" )  
    end
    
    if downpayment_usage_amount.present? and downpayment_usage_amount < BigDecimal("0")
      errors.add(:downpayment_usage_amount , "Tidak boleh negative" )  
    end
    
    if downpayment_addition_amount.present? and downpayment_addition_amount < BigDecimal("0")
      errors.add(:downpayment_addition_amount , "Tidak boleh negative" )  
    end
  end
  
  def cash_account_id_must_not_be_present_if_only_payment_using_downpayment
    if not is_only_downpayment_usage?
      if not cash_account_id.present? 
        errors.add(:cash_account_id , "Harus Dipilih" )  
      end
    end
  end
  
  def payment_method_must_be_matching_with_payment_scheme
    if is_only_downpayment_usage? 
      if payment_method !=  PAYMENT_METHOD_CASE[:only_downpayment][:value]
        errors.add(:payment_method , "Pilih \"Hanya menggunakan downpayment\"" ) 
      end
    else
      if payment_method ==  PAYMENT_METHOD_CASE[:only_downpayment][:value]
        errors.add(:payment_method , "Pilih selain \"Hanya menggunakan downpayment\"" ) 
      end
    end
  end
  
  def validate_downpayment_usage_is_less_than_remaining_downpayment
    customer = self.customer 
    if has_downpayment_usage?
      if downpayment_usage_amount > customer.remaining_downpayment
        errors.add(:downpayment_usage_amount , "Tidak boleh lebih dari #{customer.remaining_downpayment}" ) 
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
    
    new_object.customer_id                 = params[:customer_id]
    new_object.amount_paid                 = BigDecimal( params[:amount_paid] ) 
    new_object.payment_method              = params[:payment_method]
    new_object.cash_account_id             = params[:cash_account_id]
    new_object.note                        = params[:note]
    new_object.downpayment_addition_amount = params[:downpayment_addition_amount]
    new_object.downpayment_usage_amount    = params[:downpayment_usage_amount]
    # new_object.description               = params[:description]
    
    if new_object.is_only_downpayment_usage?
      new_object.payment_method = PAYMENT_METHOD_CASE[:only_downpayment][:value]
    end
  
    if new_object.save
      new_object.generate_code
    end
    
    return new_object
  end
  
  def is_only_downpayment_addition?
    zero_value  = BigDecimal("0")
    self.downpayment_addition_amount > zero_value && 
      self.downpayment_usage_amount == zero_value && 
      self.amount_paid == zero_value 
  end
  
  def has_downpayment_addition? 
    self.downpayment_addition_amount > BigDecimal("0")  
  end
  
  def is_only_downpayment_usage?
    zero_value = BigDecimal("0")
    self.downpayment_addition_amount == zero_value && 
      self.downpayment_usage_amount > zero_value && 
      self.amount_paid == zero_value
  end
  
  def has_downpayment_usage?
    self.downpayment_usage_amount > BigDecimal('0')
  end
  
  def update_by_employee( employee, params )  
    
    self.creator_id      = employee.id 
    self.customer_id     = params[:customer_id]
    self.amount_paid     = BigDecimal( params[:amount_paid] ) 
    self.payment_method  = params[:payment_method]
    self.cash_account_id = params[:cash_account_id]
    self.note            = params[:note]
    
    self.downpayment_addition_amount = params[:downpayment_addition_amount]
    self.downpayment_usage_amount = params[:downpayment_usage_amount]
    # self.description = params[:description]

    self.save 
    
    return self 
  end
  
  def invoice_payment_amount
    self.amount_paid + self.downpayment_usage_amount
  end
  
  def generate_code
    
    start_datetime = Date.today.at_beginning_of_month.to_datetime
    end_datetime = Date.today.next_month.at_beginning_of_month.to_datetime
    
    counter = self.class.where{
      (self.created_at >= start_datetime)  & 
      (self.created_at < end_datetime )
    }.count
    
    if self.is_confirmed?
      counter = self.class.where{
        (self.created_at >= start_datetime)  & 
        (self.created_at < end_datetime ) & 
        (self.is_confirmed.eq true )
      }.count
    end
    
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
    
    if total_sum != self.amount_paid + self.downpayment_usage_amount
      errors.add(:amount_paid , "Jumlah yang dibayar #{self.amount_paid} tidak sesuai dengan jumlah details (#{total_sum})" ) 
    end
  end
  
  def confirm(employee) 
    return nil if employee.nil? 
    return nil if not self.is_only_downpayment_addition? and self.invoice_payments.count == 0 
    return nil if self.is_confirmed == true  
    
    verify_amount_paid_equals_total_sum
    validate_downpayment_usage_is_less_than_remaining_downpayment 
    
    return self if self.errors.size != 0  
    
    # transaction block to confirm all the sales item  + sales order confirmation 
    ActiveRecord::Base.transaction do
      self.confirmer_id = employee.id 
      self.confirmed_at = DateTime.now 
      self.is_confirmed = true 
      self.save 
      self.generate_code 
      self.invoice_payments.each do |ip|
        ip.confirm( employee )
      end
      
      
      
      if self.has_downpayment_addition? 
        DownpaymentHistory.create_downpayment_addition_history( self ) 
      end
      
      if self.has_downpayment_usage? 
        DownpaymentHistory.create_downpayment_deduction_history( self )  
      end
      
      customer  = self.customer
      customer.update_outstanding_payment
      customer.update_remaining_downpayment
    end 
    
    
  end
  
  def addition_downpayment
    self.downpayments.where(:case => DOWNPAYMENT_CASE[:addition])
  end
  
  def deduction_downpayment
    self.downpayments.where(:case => DOWNPAYMENT_CASE[:deduction])
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
