class DeliveryEntry < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :delivery
  belongs_to :sales_item 
  
  
  
  validate   :quantity_sent_is_not_zero_and_less_than_ready_quantity
  validate   :quantity_sent_weight_is_not_zero_and_less_than_ready_quantity 
  
  def quantity_sent_is_not_zero_and_less_than_ready_quantity
    sales_item = self.sales_item
    if  quantity_sent <= 0 or quantity_sent > sales_item.ready 
      errors.add(:quantity_sent , "Kuantitas harus lebih dari 0 dan kurang ato sama dengan #{sales_item.ready}" )  
    end
  end
  
  def quantity_sent_weight_is_not_zero_and_less_than_ready_quantity
    if  quantity_sent_weight <= BigDecimal('0') 
      errors.add(:quantity_sent_weight , "Berat tidak boleh kurang dari 0kg" )  
    end
  end
  
  def DeliveryEntry.create_delivery_entry( employee, delivery, sales_item,  params ) 
    return nil if employee.nil?
    return nil if sales_item.nil? 
    
    new_object = DeliveryEntry.new
    new_object.creator_id = employee.id 
    new_object.delivery_id = delivery.id 
    new_object.sales_item_id = sales_item.id 
    
    new_object.quantity_sent        = params[:quantity_sent]       
    new_object.quantity_sent_weight = BigDecimal( params[:quantity_sent_weight ])
    
    
    if new_object.save 
      new_object.generate_code 
    end
    
    return new_object 
  end
  
  
  def generate_code
    string = "DE" + "/" + 
              self.created_at.year.to_s + '/' + 
              self.created_at.month.to_s+ '/' + 
              self.id .to_s
              
    self.code =  string 
    self.save 
  end
  
  def confirm 
    return nil if self.is_confirmed == true  
    self.is_confirmed = true 
    self.save 
    
    sales_item = self.sales_item 
    
    sales_item.update_ready_statistics
    sales_item.update_on_delivery_statistics
  end
  
  def finalize
    
    return nil if self.is_finalized == true 
    self.is_finalized = true 
    self.save
    
    sales_item = self.sales_item 
    sales_item.update_on_delivery_statistics
    sales_item.update_delivered_statistics 
  end
  
end
