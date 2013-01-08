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
    end
    
    return new_object
  end
  
  def quantity_lost
    self.delivery_entry.quantity_lost
  end
  
  def confirm
    
    sales_item = self.delivery_entry.sales_item  
    # puts "before update, pending_production: #{sales_item.pending_production}"
    # puts "before update, total production_order : #{sales_item.production_orders.sum('quantity')}"
    # 
    
    self.is_confirmed = true 
    self.save 
    ProductionOrder.generate_delivery_lost_production_order( self  )
     #    
     # puts "initial delivery_lost: #{sales_item.number_of_delivery_lost}"
     # 
     # sales_item.update_delivery_lost
     # sales_item.reload 
     # puts "final delivery_lost: #{sales_item.number_of_delivery_lost}"
     # 
     # 
     # 
     # sales_item.update_pending_production  # after addition of production order 
     # sales_item.reload 
     # puts "after update, pending_production: #{sales_item.pending_production}"
     # puts "after update, total production_order : #{sales_item.production_orders.sum('quantity')}"
    
    sales_item.update_on_delivery_lost_entry_confirm
  end
end
