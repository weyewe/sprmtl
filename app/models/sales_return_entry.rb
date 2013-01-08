class SalesReturnEntry < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :sales_item 
  belongs_to :delivery_entry 
  belongs_to :sales_return
  
  validates_presence_of :sales_item_id 
  validates_presence_of :delivery_entry_id 
  
  def SalesReturnEntry.create_by_employee( employee, sales_return, delivery_entry)
    
    new_object = SalesReturnEntry.new 
    new_object.creator_id = employee.id 
    new_object.delivery_entry_id = delivery_entry.id 
    new_object.sales_item_id = delivery_entry.sales_item_id 
    new_object.sales_return_id = sales_return.id 
    
    new_object.save 
  end
  
  def update_return_handling( params ) 
    self.quantity_for_production  =  params[:quantity_for_production]
    self.weight_for_production    =  BigDecimal( params[:weight_for_production] )
    
    self.quantity_for_post_production = params[:quantity_for_post_production]
    self.weight_for_post_production   = BigDecimal( params[:weight_for_post_production] )
    
    self.validate_return_handling 
    
    if self.errors.size > 0 
      return self
    end
    
    self.save 
    return self 
  end
  
  def quantity_returned 
    self.delivery_entry.quantity_returned
  end
    
  def validate_total_quantity_is_equal_to_the_sales_return_quantity
    if quantity_for_production  + quantity_for_post_production != self.quantity_returned
      msg = "Jumlah retur: #{self.quantity_returned}."+ 
            " Jumlah dari produksi (#{self.quantity_for_production}) + " + 
            " post produksi (#{self.quantity_for_post_production}) + " + 
            'tidak sesuai'
      self.errors.add(:quantity_for_production ,  msg )  
      self.errors.add(:quantity_for_post_production ,  msg  )  
    end 
  end
  
  def validate_the_sales_return_quantity_to_be_processed_is_valid
    if not quantity_for_production.present?  or quantity_for_production < 0 
      self.errors.add(:quantity_for_production , "Jumlah tidak boleh kurang dari 0" )  
    end
    
    
    
    # post production
    
    if not quantity_for_post_production.present?  or quantity_for_post_production < 0 
      self.errors.add(:quantity_for_post_production , "Jumlah tidak boleh kurang dari 0" )  
    end
    
    
  end
  
  def validate_the_weight_to_be_valid
    if quantity_for_production.present? and quantity_for_production > 0  and
        weight_for_production  <= BigDecimal('0')
       self.errors.add(:weight_for_production , "Berat total tidak boleh 0" )     
    end
    
    if  quantity_for_production.present?  and quantity_for_production == 0  and 
              weight_for_production > BigDecimal('0')
      self.errors.add(:weight_for_production , "Berat harus 0 karena kuantitas lebur ulang = 0" )  
    end
    
    if quantity_for_post_production.present? and quantity_for_post_production > 0  and
        weight_for_post_production <= BigDecimal('0')
       self.errors.add(:weight_for_post_production , "Berat total tidak boleh 0" )     
    end
    
    if  quantity_for_post_production.present?  and quantity_for_post_production == 0  and 
              weight_for_post_production > BigDecimal('0')
      self.errors.add(:weight_for_post_production , "Berat harus 0 karena kuantitas perbaiki  = 0" )  
    end
  end
  
  
  def validate_return_handling
    validate_total_quantity_is_equal_to_the_sales_return_quantity
    
    validate_the_sales_return_quantity_to_be_processed_is_valid
    
    validate_the_weight_to_be_valid 
  end
  
  def confirm
    return nil if self.is_confirmed == true 
    
    
    self.validate_return_handling 
    
    if  self.errors.size != 0 
      # puts("AAAAAAAAAAAAAAAA THe sibe kia is NOT  valid")
      
      # self.errors.messages.each do |key, values| 
      #   puts "The key is #{key.to_s}"
      #   values.each do |value|
      #     puts "\tthe value is #{value}"
      #   end
      # end
      
      raise ActiveRecord::Rollback, "Call tech support!" 
    end
    
    self.is_confirmed = true 
    self.save 
    
    ProductionOrder.generate_sales_return_production_order( self  )
    PostProductionOrder.generate_sales_return_repair_post_production_order( self ) 
    
    self.reload
    
    
    
    sales_item = self.delivery_entry.sales_item 
    sales_item.reload 
    sales_item.update_on_sales_return_confirm
     #   
     # sales_item.update_pending_production 
     # sales_item.reload 
     # sales_item.update_pending_post_production
    
  end
end
