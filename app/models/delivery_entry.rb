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
  
  def validate_post_production_quantity 
    if quantity_confirmed.nil? or quantity_confirmed < 0 
      self.errors.add(:quantity_confirmed , "Tidak boleh kurang dari 0" ) 
    end
    
    if quantity_returned.nil? or quantity_returned < 0 
      self.errors.add(:quantity_returned , "Tidak boleh kurang dari 0" ) 
    end
    
    if quantity_lost.nil? or quantity_lost < 0 
      self.errors.add(:quantity_lost , "Tidak boleh kurang dari 0" ) 
    end
  end
  
  def validate_post_production_total_sum
    if self.quantity_confirmed + self.quantity_returned + self.quantity_lost != self.quantity_sent 
      msg = "Jumlah yang terkirim: #{self.quantity_sent}. Konfirmasi + Retur + Hilang tidak sesuai."
      self.errors.add(:quantity_confirmed , msg ) 
      self.errors.add(:quantity_returned ,  msg ) 
      self.errors.add(:quantity_lost ,      msg ) 
    end
  end
  
  
  def validate_post_production_update
    self.validate_post_production_quantity
    # return self if not self.valid? 
     
    self.validate_post_production_total_sum
    # return self if not self.valid? 
    
    self.validate_returned_item_quantity_weight
    # return self if not self.valid?
  end
    
  def update_post_delivery( employee, params ) 
    return nil if employee.nil? 
    return nil if not self.is_confirmed?
    
    self.quantity_confirmed         = params[:quantity_confirmed]
    self.quantity_returned          = params[:quantity_returned]
    self.quantity_returned_weight   = BigDecimal( params[:quantity_returned_weight] ) 
    self.quantity_lost              = params[:quantity_lost]
    
    
    # validation 
    
    self.validate_post_production_update
    
    return self if not self.valid?
    
    self.save  
    return self  
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
    return nil if self.is_confirmed == false 
    return nil if self.is_finalized == true 
    
    
    # self.validate_post_production_quantity
    # self.validate_post_production_total_sum
    # self.validate_returned_item_quantity_weight
    self.validate_post_production_update
    
    if not self.valid?
      puts("AAAAAAAAAAAAAAAA THe sibe kia is NOT  valid")
      raise ActiveRecord::Rollback, "Call tech support!" 
    else
      puts("BBBBBBBBBBBBBBBBBBB THe sibe kia is valid")
    end
    
    
    self.is_finalized = true 
    self.save
    
    sales_item = self.sales_item 
    sales_item.update_on_delivery_statistics
    sales_item.update_delivered_statistics 
  end
  
end
