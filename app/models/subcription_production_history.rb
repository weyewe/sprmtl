class SubcriptionProductionHistory < ActiveRecord::Base
  
  has_many :production_histories
  belongs_to :sales_item_subcription
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
  validate :no_excess_production 
 

   

  def no_all_zero_quantity
    if  ok_quantity.present? and broken_quantity.present? and repairable_quantity.present? and
      ok_quantity == 0  and  broken_quantity == 0 and repairable_quantity == 0 
      errors.add(:ok_quantity , "OK, gagal, dan perbaiki tidak boleh bernilai 0 bersamaan" ) 
      errors.add(:broken_quantity , "OK, gagal, dan perbaiki tidak boleh bernilai 0 bersamaan" )   
      errors.add(:repairable_quantity , "OK, gagal, dan perbaiki tidak boleh bernilai 0 bersamaan" )  
    end
  end
  
  def no_negative_quantity
    if ok_quantity.present? and ok_quantity < 0 
      errors.add(:ok_quantity , "Kuantitas tidak boleh lebih kecil dari 0" ) 
    end
    
    if broken_quantity.present? and  broken_quantity <0 
      errors.add(:broken_quantity , "Kuantitas tidak boleh lebih kecil dari 0" )   
    end 
    
    if repairable_quantity.present? and  repairable_quantity < 0 
      errors.add(:repairable_quantity , "Kuantitas tidak boleh lebih kecil dari 0" )   
    end
  end
  
  def no_negative_weight
    if ok_weight.present? and ok_weight < BigDecimal('0')
      errors.add(:ok_weight , "Berat tidak boleh negative" ) 
    end
    
    if broken_weight.present? and broken_weight < BigDecimal('0')
      errors.add(:broken_weight , "Berat tidak boleh negative" )   
    end
    
    if repairable_weight.present? and repairable_weight < BigDecimal('0')
      errors.add(:repairable_weight , "Berat tidak boleh negative" )   
    end
    
    if ok_tap_weight.present? and ok_tap_weight < BigDecimal('0')
      errors.add(:ok_tap_weight , "Berat tidak boleh negative" )   
    end
    
    if repairable_tap_weight.present? and repairable_tap_weight < BigDecimal('0')
      errors.add(:repairable_tap_weight , "Berat tidak boleh negative" )   
    end
  end
  
  def prevent_zero_weight_for_non_zero_quantity
    if ok_quantity.present? and ok_weight.present? and 
        ok_quantity > 0 and ok_weight <= BigDecimal('0')
      errors.add(:ok_weight , "Berat tidak boleh 0 jika kuantity > 0 " ) 
    end
    
    if broken_quantity.present? and broken_weight.present? and 
       broken_quantity >  0  and broken_weight <=  BigDecimal('0')
      errors.add(:broken_weight , "Berat tidak boleh 0 jika kuantity > 0 " )   
    end
    
    if repairable_quantity.present? and repairable_weight.present? and 
       repairable_quantity >  0  and repairable_weight <=  BigDecimal('0')
      errors.add(:repairable_weight , "Berat tidak boleh 0 jika kuantity > 0 " )   
    end
  end
  
  def start_date_must_not_be_later_than_finish_date
    if (not start_date.nil?) and (not finish_date.nil? )  and  (start_date > finish_date)
      errors.add(:start_date , "Tanggal mulai tidak boleh sesudah tanggal selesai" ) 
    end 
  end
  
  def no_excess_production
    sales_item_subcription = self.sales_item_subcription 
    if ok_quantity.present? and ok_quantity > sales_item_subcription.pending_production 
      errors.add(:ok_quantity , "Tidak boleh lebih besar dari #{sales_item_subcription.pending_production }" ) 
    end
  end
  
  
  
  def self.create_history( employee, sales_item_subcription , params ) 
    return nil if employee.nil?  or sales_item_subcription.nil? 
    return nil if sales_item_subcription.has_unconfirmed_production_history? 
    
    new_object  = self.new
    new_object.sales_item_subcription_id = sales_item_subcription.id 
    new_object.creator_id = employee.id 
     
  
    # if not params[:ok_quantity].nil? and params[:ok_quantity].to_i > sales_item_subcription.pending_production 
    #   new_object.errors.add(:ok_quantity , "Maksimal pending production: #{sales_item_subcription.pending_production}" ) 
    #   return new_object 
    # end
    
    new_object.ok_quantity         = params[:ok_quantity]
    new_object.repairable_quantity = params[:repairable_quantity]
    new_object.broken_quantity     = params[:broken_quantity] 
    new_object.ok_weight           = BigDecimal( params[:ok_weight]           )
    new_object.repairable_weight   = BigDecimal( params[:repairable_weight]   )
    new_object.broken_weight       = BigDecimal( params[:broken_weight]       )
    new_object.start_date          = params[:start_date] 
    new_object.finish_date         = params[:finish_date] 

    
    if new_object.save   
    end
    
   
    
    return new_object 
  end
  
  def update_history( employee, sales_item_subcription , params ) 
    return nil if employee.nil?  or sales_item_subcription.nil? 
    return nil if self.is_confirmed == true 
    
    self.creator_id = employee.id 
    self.ok_quantity         = params[:ok_quantity]
    self.repairable_quantity = params[:repairable_quantity]
    self.broken_quantity     = params[:broken_quantity] 
    self.ok_weight           = BiDecimal( params[:ok_weight]         )
    self.repairable_weight   = BiDecimal( params[:repairable_weight] )
    self.broken_weight       = BiDecimal( params[:broken_weight]     )
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
    return nil if self.is_confirmed == true 
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
    puts "pass the employee check"
    return nil if self.is_confirmed == true 
    puts "pass the is_confirmed check"
    
    ActiveRecord::Base.transaction do
      
      
      
      self.is_confirmed = true 
      self.confirmer_id = employee.id
      self.confirmed_at = DateTime.now 
      self.save
      
      puts "Total error in confirm: #{self.errors.size}"
      if  self.errors.size != 0  
        puts "There is rollback!! on confirm"
        self.errors.messages.each do |msg|
          puts "#{msg}"
        end
        raise ActiveRecord::Rollback, "Call tech support!" 
      end
      
      puts "\n\n*******************"
      puts "Gonna distribute "
      self.distribute_production_result  
    end
    
  end
  
  
  
  
  
  # will distribute production result.. should not called twice. 
  # what if admin needs to update? get another method to handle the update:
  # => to delete the excess 
  # => to create extra production history 
  def distribute_production_result
    return nil if self.is_confirmed == false 
    
    ok_quantity = self.ok_quantity
    repairable_quantity = self.repairable_quantity
    broken_quantity = self.broken_quantity 
    
    sales_item_subcription = self.sales_item_subcription
    
    if sales_item_subcription.pending_production_sales_items.count == 0 
      raise ActiveRecord::Rollback, "Call tech support!" 
      return
    end
    
    
    total_pending = sales_item_subcription.pending_production  ## aggregate over all shite 
    
    sales_item_subcription.pending_production_sales_items.each do |sales_item| 
      assigned_ok_quantity = 0
      assigned_repairable_quantity = 0 
      assigned_broken_quantity = 0 
      
      # if there is nothing else to distribute, just break. 
      # stop the shit. and move on 
      if ok_quantity == 0 and repairable_quantity == 0 and broken_quantity == 0 
        break 
      end
      
      if sales_item.pending_production >= ok_quantity and ok_quantity != 0 
        assigned_ok_quantity = ok_quantity 
        ok_quantity  = 0 
      else
        assigned_ok_quantity = sales_item.pending_production 
        ok_quantity = ok_quantity - sales_item.pending_production 
      end
      
      # the post production order is assigned only once in the beginning
      if repairable_quantity != 0 
        assigned_repairable_quantity = repairable_quantity
        repairable_quantity =  0  
      end
      
      if broken_quantity != 0 
        assigned_broken_quantity = broken_quantity
        broken_quantity =  0  
      end
       
      ProductionHistory.create_history( sales_item_subcription, self, sales_item , {
        :ok_quantity           => assigned_ok_quantity, 
        :repairable_quantity   => assigned_repairable_quantity, 
        :broken_quantity       => assigned_broken_quantity 
      }) 
    end
  end
  
  def is_a_number?(s)
    s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true 
  end
end
