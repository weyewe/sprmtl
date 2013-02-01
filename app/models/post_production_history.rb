class PostProductionHistory < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :sales_item 
  belongs_to :sales_item_subcription
  validates_presence_of   :ok_quantity,  :broken_quantity, :bad_source_quantity# , 
  #                           # :ok_weight,   :broken_weight,   :bad_source_weight ,  
  #                           # :start_date, :finish_date
                          
  validates_numericality_of :ok_quantity, :broken_quantity  ,  :bad_source_quantity# , 
  #                           :ok_weight, :broken_weight    , :bad_source_weight         
                  
   
  validate :no_all_zero_quantity
  validate :no_negative_quantity
  # validate :no_negative_weight
  # validate :prevent_zero_weight_for_non_zero_quantity
  # validate  :prevent_excess_post_production

   

  def no_all_zero_quantity
    if  ok_quantity.present? and broken_quantity.present? and bad_source_quantity.present? and 
        ok_quantity == 0  and  broken_quantity == 0   and bad_source_quantity == 0 
      errors.add(:ok_quantity , "OK, gagal, dan perbaiki tidak boleh bernilai 0 bersamaan" ) 
      errors.add(:broken_quantity , "OK, gagal, dan perbaiki tidak boleh bernilai 0 bersamaan" )   
      errors.add(:bad_source_quantity , "OK, gagal, dan perbaiki tidak boleh bernilai 0 bersamaan" )   
    end
  end
  
  def no_negative_quantity
    if ok_quantity.present? and ok_quantity < 0 
      errors.add(:ok_quantity , "Kuantitas tidak boleh lebih kecil dari 0" ) 
    end
    
    if broken_quantity.present? and  broken_quantity <0 
      errors.add(:broken_quantity , "Kuantitas tidak boleh lebih kecil dari 0" )   
    end 
    
    if bad_source_quantity.present? and  bad_source_quantity <0 
      errors.add(:bad_source_quantity , "Kuantitas tidak boleh lebih kecil dari 0" )   
    end
  end
  
  # def no_negative_weight
  #   if ok_weight.present? and ok_weight < BigDecimal('0')
  #     errors.add(:ok_weight , "Berat tidak boleh negative" ) 
  #   end
  #   
  #   if broken_weight.present? and  broken_weight < BigDecimal('0')
  #     errors.add(:broken_weight , "Berat tidak boleh negative" )   
  #   end
  #   
  #   if bad_source_weight.present? and  bad_source_weight < BigDecimal('0')
  #     errors.add(:bad_source_weight , "Berat tidak boleh negative" )   
  #   end
  # 
  # end
  
  # def prevent_zero_weight_for_non_zero_quantity
  #   if ok_quantity.present? and ok_weight.present? and ok_quantity > 0 and ok_weight <= BigDecimal('0')
  #     errors.add(:ok_weight , "Berat tidak boleh 0 jika kuantity > 0 " ) 
  #   end
  #   
  #   if broken_quantity.present? and broken_weight.present? and broken_quantity >  0  and broken_weight <=  BigDecimal('0')
  #     errors.add(:broken_weight , "Berat tidak boleh 0 jika kuantity > 0 " )   
  #   end
  #   
  #   if bad_source_quantity.present? and bad_source_weight.present? and bad_source_quantity >  0  and bad_source_weight <=  BigDecimal('0')
  #     errors.add(:bad_source_weight , "Berat tidak boleh 0 jika kuantity > 0 " )   
  #   end
  # end
  
  # def prevent_excess_post_production
  #   sales_item = self.sales_item
  #   pending_post_production = sales_item.pending_post_production
  #   # puts "pending post production from validation: #{pending_post_production}"
  #   
  #   if ok_quantity.present? and broken_quantity.present? and bad_source_quantity.present?  and 
  #         ( ok_quantity + broken_quantity + bad_source_quantity > sales_item.pending_post_production ) 
  #     errors.add(:ok_quantity , "Jumlah kuantitas oK, gagal, dan kuantitas rusak tidak boleh lebih dari #{pending_post_production}" )   
  #     errors.add(:broken_quantity , "Jumlah kuantitas oK, gagal, dan kuantitas rusak tidak boleh lebih dari #{pending_post_production}" )
  #     errors.add(:bad_source_quantity , "Jumlah kuantitas oK, gagal, dan kuantitas rusak tidak boleh lebih dari #{pending_post_production}" )
  #   end
  # end
  
  
  
  def self.create_history( sales_item_subcription, subcription_post_production_history,  sales_item , params ) 
    return nil if   sales_item_subcription.nil? or subcription_post_production_history.nil? or sales_item.nil? 
    return nil if sales_item_subcription.has_unconfirmed_post_production_history? 
    
    new_object  = self.new
    new_object.sales_item_id = sales_item.id 
    new_object.creator_id    = subcription_post_production_history.creator_id 
    new_object.is_confirmed  = true
     
  
    
    new_object.ok_quantity         = params[:ok_quantity]
    new_object.broken_quantity     = params[:broken_quantity] 
    new_object.bad_source_quantity = params[:bad_source_quantity] 
    new_object.subcription_post_production_history_id = subcription_post_production_history.id 
     
  
    if not new_object.save 
      # raise the shite 
      
      puts "CAN't SAVE PRODUCTION HISTORY"
      puts "Total error: #{new_object.errors.size}"
      new_object.errors.messages.each do |msg|
        puts msg 
      end
      raise ActiveRecord::Rollback, "Call tech support!" 
      return
    end
    
    # auto confirm 
    # new_object.update_processed_quantity
    # sales_item.reload 
    # sales_item.generate_next_phase_after_production( new_object ) 
    # sales_item.update_on_production_history_confirm
    # 
    # 
    # 
    new_object.update_processed_quantity
    sales_item.reload 
    sales_item.generate_next_phase_after_post_production( new_object )   
    sales_item.update_on_post_production_history_confirm
   
    
    return new_object 
  end
  
  # def update_history( employee, sales_item , params ) 
  #   return nil if employee.nil?  or sales_item.nil? 
  #   return nil if self.is_confirmed == true 
  #   
  #   
  #   
  #   self.creator_id          = employee.id
  #   self.sales_item_id       = sales_item.id
  #   self.ok_quantity         = params[:ok_quantity]
  #   self.broken_quantity     = params[:broken_quantity]  
  #   self.bad_source_quantity = params[:bad_source_quantity]  
  # 
  #   if self.save  
  #     # new_object.update_processed_quantity 
  #     # sales_item.update_pre_production_statistics 
  #   end
  #   
  #   return self 
  # end
  
  def delete(employee)
    return nil if employee.nil?
  
    self.destroy if self.is_confirmed == false 
  end
  
  
  def update_processed_quantity 
    self.processed_quantity = self.ok_quantity  + 
                                  self.broken_quantity + self.bad_source_quantity 
    self.save
  end
  
  def quantity_to_be_reproduced
    # if the sales item includes production 
    self.broken_quantity + self.bad_source_quantity 
  end
  
  
  
  # def confirm( employee )
  #   return nil if employee.nil? 
  #   return nil if self.is_confirmed == true 
  #   
  #   ActiveRecord::Base.transaction do
  #     
  #     
  #     self.is_confirmed = true 
  #     self.confirmer_id = employee.id
  #     self.confirmed_at = DateTime.now 
  #     self.save
  #     self.update_processed_quantity
  #     if  self.errors.size != 0  
  #       raise ActiveRecord::Rollback, "Call tech support!" 
  #     end
  #     
  #     sales_item = self.sales_item
  #      
  #     sales_item.generate_next_phase_after_post_production( self )   
  #     sales_item.update_on_post_production_history_confirm    
  #   end
  #   
  # end
  
  
  
  def is_a_number?(s)
    s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true 
  end
end
