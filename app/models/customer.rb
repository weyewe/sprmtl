class Customer < ActiveRecord::Base
  attr_accessible :name, :contact_person, :phone, :mobile , :email, :bbm_pin, :address, :town_id , :office_address, :delivery_address
  
  has_many :sales_orders 
  has_many :deliveries
  has_many :payments
  has_many :invoices 
  has_many :downpayment_histories
  
 
  has_many :sales_items  
  has_many :sales_item_subcriptions 
  
  has_many :template_sales_items, :through => :sales_item_subcriptions
  

  
  
  
  validates_presence_of :name 
  # validates_uniqueness_of :name
  
  has_many :sales_orders 
  belongs_to :town 
  
  validate :unique_non_deleted_name 
  
  def unique_non_deleted_name
    current_service = self
     
     # claim.status_changed?
    if not current_service.name.nil? 
      if not current_service.persisted? and current_service.has_duplicate_entry?  
        errors.add(:name , "Sudah ada customer  dengan nama sejenis" )  
      elsif current_service.persisted? and 
            current_service.name_changed?  and
            current_service.has_duplicate_entry?   
            # if duplicate entry is itself.. no error
            # else.. some error
            
          if current_service.duplicate_entries.count ==1  and 
              current_service.duplicate_entries.first.id == current_service.id 
          else
            errors.add(:name , "Sudah ada customer  dengan nama sejenis" )  
          end 
      end
    end
  end
  
  def has_duplicate_entry?
    current_service=  self  
    self.class.find(:all, :conditions => ['lower(name) = :name and is_deleted = :is_deleted ', 
                {:name => current_service.name.downcase, :is_deleted => false }]).count != 0  
  end
  
  def duplicate_entries
    current_service=  self  
    return self.class.find(:all, :conditions => ['lower(name) = :name and is_deleted = :is_deleted ', 
                {:name => current_service.name.downcase, :is_deleted => false }]) 
  end
  
  def new_vehicle_registration( employee ,  vehicle_params ) 
    id_code = vehicle_params[:id_code]
    if not id_code.present? 
      return nil
    end
    
    
    self.vehicles.create :id_code =>  id_code.upcase.gsub(/\s+/, "") 
  end
  
  def self.active_objects
    self.where(:is_deleted => false).order("created_at DESC")
  end
  
  def delete
    self.is_deleted = true
    self.save 
  end
  
  
  def all_ready_sales_items 
    customer = self 
    SalesItem.joins(:sales_order).where(
      :sales_order => {:customer_id => customer.id }
    ).where{(ready.not_eq 0)}
  end
  
  def all_selectable_sales_items
    selectables  =  self.all_ready_sales_items 
    result = []
    selectables.each do |selectable| 
      result << [ "#{selectable.code} | Ready: #{selectable.ready}" , 
                      selectable.id ]  
    end
    return result
  end
  
  def all_only_post_production_sales_items
    customer = self 
    selectables = SalesItem.joins(:sales_order).where(
      :sales_order => {:customer_id => customer.id },
      :is_pre_production => false, 
      :is_production => false, 
      :is_post_production => true
    )
    result = []
    selectables.each do |selectable| 
      result << [ "#{selectable.code}" , 
                      selectable.id ]  
    end
    return result
  end
  
  def all_selectable_unpaid_invoices
    selectables  =  self.invoices.where(:is_paid => false ).order("created_at ASC") 
    result = []
    selectables.each do |selectable| 
      result << [ "#{selectable.code} |  #{selectable.confirmed_pending_payment.to_s}" , 
                      selectable.id ]  
    end
    return result
  end
  
  def self.all_with_outstanding_payments
    customer_id_list = Invoice.where(:is_paid => false).pluck(:customer_id).uniq
    Customer.includes(:invoices).where(:id => customer_id_list )
  end
  

  
  def pending_confirmed_payment_amount
    self.invoices.sum("amount_payable") - self.payments.where(:is_confirmed => true).sum("amount_paid")
  end
  
  def has_unconfirmed_payment?
    self.payments.where(:is_confirmed => false).count != 0 
  end
  
=begin
  TRACKING OUTSTANDING PAYMENT + REMAINING DOWNPAYMENT 
=end

  def update_outstanding_payment
    total = BigDecimal("0")
    self.invoices.where(:is_paid => false).each do |invoice|
      total += invoice.confirmed_pending_payment
    end
    
    self.outstanding_payment = total 
    self.save 
  end
  
  def update_remaining_downpayment
    total = BigDecimal("0")
    
    total_addition = self.downpayment_histories.where(:case => DOWNPAYMENT_CASE[:addition]).sum("amount")
    total_deduction = self.downpayment_histories.where(:case => DOWNPAYMENT_CASE[:deduction]).sum("amount")
    
    self.remaining_downpayment = total_addition - total_deduction 
    self.save 
  end
  
  
   
end
