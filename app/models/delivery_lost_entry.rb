class DeliveryLostEntry < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :sales_item 
  belongs_to :delivery_entry 
  belongs_to :delivery_lost
  
  def DeliveryLostEntry.create_by_employee( employee, delivery_lost, delivery_entry)
    
    new_object = DeliveryLostEntry.new 
    new_object.creator_id = employee.id 
    new_object.delivery_entry_id = delivery_entry.id 
    new_object.delivery_lost_id  = delivery_lost.id 
    
     
    
    if new_object.save
      ProductionOrder.generate_delivery_lost_production_order( new_object  )
      
      sales_item = new_object.delivery_entry.sales_item 
      sales_item.reload 

      sales_item.update_pending_production 
      sales_item.reload
    end
    
    return new_object
  end
  
  def quantity_lost
    self.delivery_entry.quantity_lost
  end
end
