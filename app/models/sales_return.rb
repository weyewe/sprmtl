class SalesReturn < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :delivery
  has_many :sales_return_entries
  
  def SalesReturn.create_by_employee( employee, delivery )
    return nil if employee.nil?
    return nil if delivery.nil? 
    return nil if delivery.is_confirmed == false 
    return nil if delivery.is_finalized == false 
    return nil if not delivery.has_sales_return? 
    
    new_object = SalesReturn.new 
    new_object.creator_id   = employee.id 
    new_object.delivery_id  = delivery.id 
    
    if new_object.save
      new_object.generate_code
      new_object.generate_sales_return_entries(employee) 
    end
    
    return new_object 
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
    
    
    string = "SR" + "/" + 
              self.created_at.year.to_s + '/' + 
              self.created_at.month.to_s + '/' + 
              counter.to_s
              
    self.code =  string 
    self.save 
  end
  
  def generate_sales_return_entries(employee)
    return nil if not self.delivery.has_sales_return?
      
    self.delivery.delivery_entries.where{ ( quantity_returned.not_eq 0 )}.each do |delivery_entry|
      SalesReturnEntry.create_by_employee( employee ,self,  delivery_entry )
    end
  end
  
  def confirm(employee) 
    return nil if employee.nil? 
    return nil if self.is_confirmed == true  
    
    # transaction block to confirm all the sales item  + sales order confirmation 
    ActiveRecord::Base.transaction do
      self.confirmer_id = employee.id 
      self.confirmed_at = DateTime.now 
      self.is_confirmed = true 
      self.save 
      
      self.sales_return_entries.each do |sales_return_entry|
        sales_return_entry.confirm 
      end
    end 
  end
end
