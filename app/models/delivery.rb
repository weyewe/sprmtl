class Delivery < ActiveRecord::Base
  has_many :delivery_entries
  
  validates_presence_of :creator_id
  validates_presence_of :customer_id 
  has_one :delivery_lost 
  has_one :sales_return 
  
  
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
  
  def generate_code
    string = "DO" + "/" + 
              self.created_at.year.to_s + '/' + 
              self.created_at.month.to_s + '/' + 
              self.id.to_s
              
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
      self.delivery_entries.each do |delivery_entry|
        delivery_entry.confirm 
      end
    end 
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

      # why no rollback?
      self.delivery_entries.each do |delivery_entry|
        delivery_entry.finalize 
      end

      # create SalesReturn
      
      if self.any_sales_return? 
        SalesReturn.create_by_employee( employee  , self  ) 
      end
      
      # create DeliveryLost
      if self.any_delivery_lost? 
        DeliveryLost.create_by_employee( employee, self )
      end
      
      
      puts "DOING SHITE AS NORMAL, NO ROLLBACK"
    end 

   
    
  end
    
  
  
  # attr_accessible :title, :body
end
