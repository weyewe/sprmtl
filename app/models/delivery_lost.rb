class DeliveryLost < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :delivery 
  has_many :delivery_lost_entries 
  
  def DeliveryLost.create_by_employee( employee, delivery )
    return nil if employee.nil?
    return nil if delivery.nil? 
    return nil if delivery.is_confirmed == false 
    return nil if delivery.is_finalized == false 
    return nil if not delivery.has_delivery_lost? 
    
    new_object = DeliveryLost.new 
    new_object.creator_id   = employee.id 
    new_object.delivery_id  = delivery.id 
    
    if new_object.save
      new_object.generate_code
      new_object.generate_delivery_lost_entries(employee) 
    end
    
    return new_object 
  end
  
  def generate_code
    string = "DL" + "/" + 
              self.created_at.year.to_s + '/' + 
              self.created_at.month.to_s + '/' + 
              self.id.to_s
              
    self.code =  string 
    self.save 
  end
  
  def generate_delivery_lost_entries(employee)
    return nil if not self.delivery.has_delivery_lost?
      
    self.delivery.delivery_entries.where{ ( quantity_lost.not_eq 0 )}.each do |delivery_entry|
      DeliveryLostEntry.create_by_employee( employee ,self,  delivery_entry )
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
      
      self.delivery_lost_entries.each do |delivery_lost_entry|
        delivery_lost_entry.confirm 
      end
    end 
  end
end
