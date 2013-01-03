class PreProductionHistory < ActiveRecord::Base
  # attr_accessible :processed_quantity, :ok_quantity, :broken_quantity, 
  #                  :order_date , :finish_date 
  belongs_to :sales_item
  
  validates_presence_of   :ok_quantity, :broken_quantity,  
                           :start_date, :finish_date
                           
  validates_numericality_of :ok_quantity, :broken_quantity               
  validate :no_negative_quantity, :no_zero_sum 
  validate :start_date_must_not_be_later_than_finish_date
  

  def no_negative_quantity 
    if  ok_quantity < 0 
      errors.add(:ok_quantity , "Hasil yang sukses tidak boleh < 0 " )  
    end
    
    if  broken_quantity < 0 
      errors.add(:broken_quantity , "Hasil yang gagal tidak boleh < 0 " )  
    end
  end
  
  
  def no_zero_sum
    if ok_quantity.present? and broken_quantity.present?
      if ok_quantity == 0 and  broken_quantity == 0 
        errors.add(:ok_quantity , "Kuantitas sukses dan gagal tidak boleh sama-sama 0" ) 
      end
    end
  end
  
  def start_date_must_not_be_later_than_finish_date
    if (not start_date.nil?) and (not finish_date.nil? )  and  (start_date > finish_date)
      errors.add(:start_date , "Tanggal mulai tidak boleh sesudah tanggal selesai" ) 
    end
  end
  
  

  
  def PreProductionHistory.create_history( employee, sales_item , params ) 
    return nil if employee.nil?  or sales_item.nil? 
    return nil if sales_item.has_unconfirmed_pre_production_history?
    
    new_object  = PreProductionHistory.new
    
    
    new_object.creator_id         =  employee.id
    new_object.sales_item_id      =  sales_item.id
    new_object.ok_quantity        =  params[:ok_quantity]
    new_object.broken_quantity    =  params[:broken_quantity]  
    new_object.start_date         =  params[:start_date]
    new_object.finish_date        =  params[:finish_date]
    
    if new_object.save  
      # new_object.update_processed_quantity 
      # sales_item.update_pre_production_statistics 
    end
    
    return new_object 
  end
  
  def update_history( employee, sales_item , params ) 
    return nil if employee.nil?  or sales_item.nil? 
    return nil if self.is_confirmed == true 
    
    
    
    self.creator_id         =  employee.id
    self.sales_item_id      =  sales_item.id
    self.ok_quantity        =  params[:ok_quantity]
    self.broken_quantity    =  params[:broken_quantity]  
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
    self.destroy if self.is_confirmed == false 
  end
  
  
  def confirm(employee)
    return nil if employee.nil? 
    return nil if self.is_confirmed == true 
    
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
      sales_item.update_pre_production_statistics
    end
  end
  
  def update_processed_quantity
    self.processed_quantity = ok_quantity + broken_quantity 
    self.save 
  end
  
  # http://railsforum.com/viewtopic.php?id=19081
  
  def is_a_number?(s)
    s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true 
  end
end
