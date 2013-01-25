class Delivery < ActiveRecord::Base
  has_many :delivery_entries
  
  validates_presence_of :creator_id
  validates_presence_of :customer_id 
  
  belongs_to :customer 
  has_one :delivery_lost 
  has_one :sales_return 
  
  has_one :invoice
  
  
  def self.create_by_employee( employee, params ) 
    return nil if employee.nil? 
    
    new_object = Delivery.new
    new_object.creator_id                 = employee.id
    new_object.customer_id                = params[:customer_id]
    new_object.delivery_address           = params[:delivery_address]
    new_object.delivery_date              = params[:delivery_date]
    
    
    if new_object.save
      new_object.generate_code
    end
    
    return new_object 
  end
  
  def delete(employee)
    return nil if employee.nil?
    return nil if self.is_confirmed?
    
    self.delivery_entries.each do |delivery_entry|
      delivery_entry.destroy 
    end
    self.destroy 
  end
  
  def update_by_employee( employee, params ) 
    return nil if employee.nil? 
    
    self.creator_id                 = employee.id
    self.customer_id                = params[:customer_id]
    self.delivery_address           = params[:delivery_address]
    self.delivery_date              = params[:delivery_date]
    
    
    if self.save
    end
    
    return self 
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
    
    
    string = "#{header}DO" + "/" + 
              self.created_at.year.to_s + '/' + 
              self.created_at.month.to_s + '/' + 
              counter.to_s 
              
    self.code =  string 
    self.save 
  end
  
  def confirm(employee) 
    return nil if employee.nil? 
    return nil if self.delivery_entries.count == 0 
    return nil if self.is_confirmed == true  
    
    # transaction block to confirm all the sales item  + sales order confirmation 
    ActiveRecord::Base.transaction do
      self.confirmer_id = employee.id 
      self.confirmed_at = DateTime.now 
      self.is_confirmed = true 
      self.save 
      self.generate_code
      
      if  self.errors.size != 0  
        raise ActiveRecord::Rollback, "Call tech support!" 
      end
      
      self.delivery_entries.each do |delivery_entry|
        delivery_entry.confirm 
      end
      
      Invoice.create_by_employee( employee  , self  ) 
      
      # by creating new invoice, we need to update outstanding payment 
      customer  = self.customer
      customer.update_outstanding_payment
    end 
  end
  
  def only_delivering_non_invoicable_goods? 
    entry_case_list = self.delivery_entries.map{ |x| x.entry_case }
    entry_case_list.uniq! 
    
    non_invoicable_entry_case = [
      DELIVERY_ENTRY_CASE[:guarantee_return ] ,
      DELIVERY_ENTRY_CASE[:technical_failure_post_production]
    ]
    
    return true if (entry_case_list - non_invoicable_entry_case).length == 0 
    
    return false  
  end
  
  
  def finalize(employee)
    return nil if employee.nil? 
    return nil if self.is_confirmed == false 
    return nil if self.is_finalized == true  
    
    # transaction block to confirm all the sales item  + sales order confirmation 

    ActiveRecord::Base.transaction do
      self.finalizer_id = employee.id 
      self.finalized_at = DateTime.now 
      self.is_finalized = true 
      self.save 
      
      invoice = self.invoice  
      
      if  self.errors.size != 0  
        raise ActiveRecord::Rollback, "Call tech support!" 
      end


      # why no rollback?
      self.delivery_entries.each do |delivery_entry|
        delivery_entry.finalize 
      end

      # create SalesReturn
      
      if self.has_sales_return? 
        SalesReturn.create_by_employee( employee  , self  ) 
      end
      #  
      #  # create DeliveryLost
      if self.has_delivery_lost? 
        delivery_lost = DeliveryLost.create_by_employee( employee, self )
        delivery_lost.confirm( employee )
      end
      
      
      
      invoice.update_amount_payable if not invoice.nil? 

      # by finalizing delivery, we adjust the outstanding payment 
      # adjustment for sales return or lost delivery 
      customer  = self.customer
      customer.update_outstanding_payment
    end 
  end
  
=begin
  SALES RETURN RELATED
=end
  def has_sales_return?
    self.delivery_entries.where{ (quantity_returned.not_eq 0 )}.count != 0 
  end
  
=begin
  SALES RETURN RELATED
=end
  def has_delivery_lost?
    self.delivery_entries.where{ (quantity_lost.not_eq 0 )}.count != 0 
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
