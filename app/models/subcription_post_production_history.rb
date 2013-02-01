class SubcriptionPostProductionHistory < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :sales_item_subcription 
  has_many :post_production_histories 
  
  validates_presence_of   :ok_quantity,  :broken_quantity, :bad_source_quantity, 
                          :ok_weight,   :broken_weight,   :bad_source_weight ,  
                          :start_date, :finish_date
                          
  validates_numericality_of :ok_quantity, :broken_quantity  ,  :bad_source_quantity, 
                          :ok_weight, :broken_weight    , :bad_source_weight         
                  
   
  validate :no_all_zero_quantity
  validate :no_negative_quantity
  validate :no_negative_weight
  validate :prevent_zero_weight_for_non_zero_quantity
  validate  :prevent_excess_post_production

   

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
  
  def no_negative_weight
    if ok_weight.present? and ok_weight < BigDecimal('0')
      errors.add(:ok_weight , "Berat tidak boleh negative" ) 
    end
    
    if broken_weight.present? and  broken_weight < BigDecimal('0')
      errors.add(:broken_weight , "Berat tidak boleh negative" )   
    end
    
    if bad_source_weight.present? and  bad_source_weight < BigDecimal('0')
      errors.add(:bad_source_weight , "Berat tidak boleh negative" )   
    end
  
  end
  
  def prevent_zero_weight_for_non_zero_quantity
    if ok_quantity.present? and ok_weight.present? and ok_quantity > 0 and ok_weight <= BigDecimal('0')
      errors.add(:ok_weight , "Berat tidak boleh 0 jika kuantity > 0 " ) 
    end
    
    if broken_quantity.present? and broken_weight.present? and broken_quantity >  0  and broken_weight <=  BigDecimal('0')
      errors.add(:broken_weight , "Berat tidak boleh 0 jika kuantity > 0 " )   
    end
    
    if bad_source_quantity.present? and bad_source_weight.present? and bad_source_quantity >  0  and bad_source_weight <=  BigDecimal('0')
      errors.add(:bad_source_weight , "Berat tidak boleh 0 jika kuantity > 0 " )   
    end
  end
  
  def prevent_excess_post_production
    sales_item_subcription = self.sales_item_subcription
    pending_post_production = sales_item_subcription.pending_post_production
    # puts "pending post production from validation: #{pending_post_production}"
    
    if ok_quantity.present? and broken_quantity.present? and bad_source_quantity.present?  and 
          ( ok_quantity + broken_quantity + bad_source_quantity > pending_post_production  ) 
      errors.add(:ok_quantity , "Jumlah kuantitas oK, gagal, dan kuantitas rusak tidak boleh lebih dari #{pending_post_production}" )   
      errors.add(:broken_quantity , "Jumlah kuantitas oK, gagal, dan kuantitas rusak tidak boleh lebih dari #{pending_post_production}" )
      errors.add(:bad_source_quantity , "Jumlah kuantitas oK, gagal, dan kuantitas rusak tidak boleh lebih dari #{pending_post_production}" )
    end
  end
  
 
  
  
  
  def self.create_history( employee,sales_item_subcription , params) 
    return nil if employee.nil?  or sales_item_subcription.nil? 
    return nil if sales_item_subcription.has_unconfirmed_post_production_history? 
    
    new_object  = self.new
    new_object.sales_item_subcription_id = sales_item_subcription.id 
     
  
    
    new_object.ok_quantity         = params[:ok_quantity]
    new_object.broken_quantity     = params[:broken_quantity] 
    new_object.bad_source_quantity = params[:bad_source_quantity] 
    
     
    
    new_object.ok_weight           = BigDecimal( params[:ok_weight]           )
    new_object.broken_weight       = BigDecimal( params[:broken_weight]       )
    new_object.bad_source_weight   = BigDecimal( params[:bad_source_weight]   )


    new_object.start_date          = params[:start_date] 
    new_object.finish_date         = params[:finish_date] 

    
    if new_object.save   
    end
    
   
    
    return new_object 
  end
  
  def update_history( employee, sales_item_subcription , params ) 
    return nil if employee.nil?  or sales_item_subcription.nil? 
    return nil if self.is_confirmed == true 
    
    
    
    self.creator_id          = employee.id
    self.ok_quantity         = params[:ok_quantity]
    self.broken_quantity     = params[:broken_quantity]  
    self.bad_source_quantity = params[:bad_source_quantity] 
    
    self.ok_weight           = BigDecimal( params[:ok_weight]         )
    self.broken_weight       = BigDecimal( params[:broken_weight]     )
    self.bad_source_weight   = BigDecimal( params[:bad_source_weight] )


    
    self.start_date         =  params[:start_date]
    self.finish_date        =  params[:finish_date]

    if self.save  
      # new_object.update_processed_quantity 
      # sales_item.update_pre_production_statistics 
    end
    
    return self 
  end
  
  def delete(employee)
    return nil if employee.nil?
    return nil if self.is_confirmed == true 
    
    self.destroy if self.is_confirmed == false 
  end
  
  
  def update_processed_quantity 
    self.processed_quantity = self.ok_quantity  + 
                                  self.broken_quantity + self.bad_source_quantity 
    self.save
  end
  
  def quantity_to_be_reproduced
    self.broken_quantity + self.bad_source_quantity 
  end
  
  
  
  def confirm( employee )
    return nil if employee.nil? 
    return nil if self.is_confirmed == true 
    
    ActiveRecord::Base.transaction do
      
      
      self.is_confirmed = true 
      self.confirmer_id = employee.id
      self.confirmed_at = DateTime.now 
      self.save
      self.update_processed_quantity
      if  self.errors.size != 0  
        raise ActiveRecord::Rollback, "Call tech support!" 
      end
      
      # sales_item = self.sales_item
      #  
      # sales_item.generate_next_phase_after_post_production( self )   
      # sales_item.update_on_post_production_history_confirm   
      
      self.distribute_post_production_result  
    end
    
  end
  
  def distribute_post_production_result
    return nil if self.is_confirmed == false 
    
    ok_quantity = self.ok_quantity
    bad_source_quantity = self.bad_source_quantity
    broken_quantity = self.broken_quantity 
    
    sales_item_subcription = self.sales_item_subcription
    
    if sales_item_subcription.pending_post_production_sales_items.count == 0 
      raise ActiveRecord::Rollback, "Call tech support!" 
      return
    end
    
    
    total_pending = sales_item_subcription.pending_post_production  ## aggregate over all shite 
    
    sales_item_subcription.pending_post_production_sales_items.each do |sales_item| 
      assigned_ok_quantity = 0
      assigned_bad_source_quantity = 0 
      assigned_broken_quantity = 0 
      
      # if there is nothing else to distribute, just break. 
      # stop the method. and move on 
      if ok_quantity == 0 and repairable_quantity == 0 and broken_quantity == 0 
        break 
      end
      
      if sales_item.pending_post_production >= ok_quantity and ok_quantity != 0 
        assigned_ok_quantity = ok_quantity 
        ok_quantity  = 0 
      else
        assigned_ok_quantity = sales_item.pending_post_production 
        ok_quantity = ok_quantity - sales_item.pending_post_production 
      end
      
      # the post production order is assigned only once in the beginning
      if bad_source_quantity != 0 
        assigned_bad_source_quantity = bad_source_quantity
        bad_source_quantity =  0  
      end
      
      if broken_quantity != 0 
        assigned_broken_quantity = broken_quantity
        broken_quantity =  0  
      end
       
      PostProductionHistory.create_history( sales_item_subcription, self, sales_item , {
        :ok_quantity           => assigned_ok_quantity, 
        :bad_source_quantity   => assigned_bad_source_quantity, 
        :broken_quantity       => assigned_broken_quantity 
      }) 
    end
  end
  
  
  
  def is_a_number?(s)
    s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true 
  end
end
