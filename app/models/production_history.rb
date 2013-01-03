class ProductionHistory < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :sales_item 
  validates_presence_of   :ok_quantity,  :broken_quantity,  :repairable_quantity,
                          :ok_weight,   :broken_weight,  :repairable_weight,
                          :start_date, :finish_date
                          
  validates_numericality_of :ok_quantity, :broken_quantity  ,  :repairable_quantity, 
                          :ok_weight, :broken_weight  , :repairable_weight
                  
   
  validate :no_all_zero_quantity
  validate :no_negative_quantity
  validate :no_negative_weight
  validate :prevent_zero_weight_for_non_zero_quantity
  validate :start_date_must_not_be_later_than_finish_date

   

  def no_all_zero_quantity
    if  ok_quantity == 0  and  broken_quantity == 0 and repairable_quantity == 0 
      errors.add(:ok_quantity , "OK, gagal, dan perbaiki tidak boleh bernilai 0 bersamaan" ) 
      errors.add(:broken_quantity , "OK, gagal, dan perbaiki tidak boleh bernilai 0 bersamaan" )   
      errors.add(:repairable_quantity , "OK, gagal, dan perbaiki tidak boleh bernilai 0 bersamaan" )  
    end
  end
  
  def no_negative_quantity
    if ok_quantity < 0 
      errors.add(:ok_quantity , "Kuantitas tidak boleh lebih kecil dari 0" ) 
    end
    
    if broken_quantity <0 
      errors.add(:broken_quantity , "Kuantitas tidak boleh lebih kecil dari 0" )   
    end 
    
    if repairable_quantity < 0 
      errors.add(:repairable_quantity , "Kuantitas tidak boleh lebih kecil dari 0" )   
    end
  end
  
  def no_negative_weight
    if ok_weight < BigDecimal('0')
      errors.add(:ok_weight , "Berat tidak boleh negative" ) 
    end
    
    if broken_weight < BigDecimal('0')
      errors.add(:broken_weight , "Berat tidak boleh negative" )   
    end
    
    if repairable_weight < BigDecimal('0')
      errors.add(:repairable_weight , "Berat tidak boleh negative" )   
    end
  end
  
  def prevent_zero_weight_for_non_zero_quantity
    if ok_quantity > 0 and ok_weight <= BigDecimal('0')
      errors.add(:ok_weight , "Berat tidak boleh 0 jika kuantity > 0 " ) 
    end
    
    if broken_quantity >  0  and broken_weight <=  BigDecimal('0')
      errors.add(:broken_weight , "Berat tidak boleh 0 jika kuantity > 0 " )   
    end
    
    if repairable_quantity >  0  and repairable_weight <=  BigDecimal('0')
      errors.add(:repairable_weight , "Berat tidak boleh 0 jika kuantity > 0 " )   
    end
  end
  
  def start_date_must_not_be_later_than_finish_date
    if (not start_date.nil?) and (not finish_date.nil? )  and  (start_date > finish_date)
      errors.add(:start_date , "Tanggal mulai tidak boleh sesudah tanggal selesai" ) 
    end 
  end
  
  
  
  def ProductionHistory.create_history( employee, sales_item , params ) 
    return nil if employee.nil?  or sales_item.nil? 
    return nil if sales_item.has_unconfirmed_production_history? 
    
    new_object  = ProductionHistory.new
    new_object.sales_item_id = sales_item.id 
    new_object.creator_id = employee.id 
     
  
    
    new_object.ok_quantity         = params[:ok_quantity]
    new_object.repairable_quantity = params[:repairable_quantity]
    new_object.broken_quantity     = params[:broken_quantity] 
    new_object.ok_weight           = params[:ok_weight] 
    new_object.repairable_weight   = params[:repairable_weight] 
    new_object.broken_weight       = params[:broken_weight] 
    new_object.start_date          = params[:start_date] 
    new_object.finish_date         = params[:finish_date] 

    
    if new_object.save   
    end
    
   
    
    return new_object 
  end
  
  def update_history( employee, sales_item , params ) 
    return nil if employee.nil?  or sales_item.nil? 
    return nil if self.is_confirmed == true 
    
    self.creator_id = employee.id 
    self.ok_quantity         = params[:ok_quantity]
    self.repairable_quantity = params[:repairable_quantity]
    self.broken_quantity     = params[:broken_quantity] 
    self.ok_weight           = params[:ok_weight] 
    self.repairable_weight   = params[:repairable_weight] 
    self.broken_weight       = params[:broken_weight] 
    self.start_date          = params[:start_date] 
    self.finish_date         = params[:finish_date]

    if self.save  
      # new_object.update_processed_quantity 
      # sales_item.update_pre_production_statistics 
    end
    
    return self 
  end
  
  def delete(employee)
    return nil if employee.nil?
    self.destroy if self.is_confirmed == false 
  end
  
  
  
  
  def update_processed_quantity 
    self.processed_quantity = self.ok_quantity  + 
                                    self.repairable_quantity + 
                                    self.broken_quantity
    self.save
  end
  
  
  
  def confirm( employee )
    return nil if employee.nil? 
    
    ActiveRecord::Base.transaction do
      self.update_processed_quantity
      
      
      self.is_confirmed = true 
      self.confirmer_id = employee.id
      self.confirmed_at = DateTime.now 
      self.save
      
      if  self.errors.size != 0  
        raise ActiveRecord::Rollback, "Call tech support!" 
      end
      
      sales_item = self.sales_item
      
       
      # if only post production
      
      sales_item.generate_next_phase_after_production( self ) 
      sales_item.update_production_statistics
       
    end
    
  end
  
  def is_a_number?(s)
    s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true 
  end
end
