class PreProductionHistory < ActiveRecord::Base
  # attr_accessible :processed_quantity, :ok_quantity, :broken_quantity, 
  #                  :order_date , :finish_date 
  belongs_to :sales_item
  
  validates_presence_of  :processed_quantity, :ok_quantity, :broken_quantity,  
                           :start_date, :finish_date
                           
  validates_numericality_of :ok_quantity, :broken_quantity               
  validate :no_negative_quantity, :no_zero_sum 
  

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
      if ok_quantity == and  broken_quantity == 0 
        errors.add(:ok_quantity , "Kuantitas sukses dan gagal tidak boleh sama-sama 0" ) 
      end
    end
  end
  
  

  
  def PreProductionHistory.create_history( employee, sales_item , param ) 
    return nil if employee.nil?  or sales_item.nil? 
    
    new_object  = PreProductionHistory.new
    
    
    new_object.creator_id         =  employee.id
    new_object.sales_item_id      =  sales_item.id
    new_object.processed_quantity =  params[:processed_quantity] 
    new_object.ok_quantity        =  params[:ok_quantity]
    new_object.broken_quantity    =  params[:broken_quantity]  
    new_object.start_date         =  params[:start_date]
    new_object.finish_date        =  params[:finish_date]
    
    if new_object.save  
      new_object.update_processed_quantity 
      sales_item.update_pre_production_statistics 
    end
    
    return new_object 
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
