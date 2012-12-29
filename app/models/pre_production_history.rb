class PreProductionHistory < ActiveRecord::Base
  attr_accessible :processed_quantity, :ok_quantity, :broken_quantity, 
                  :order_date , :finish_date 
  belongs_to :sales_item
  
  validates_presence_of  :processed_quantity, :ok_quantity, :broken_quantity, 
                        :order_date, :finish_date
                        
  validate :no_negative_quantity, :matching_quantity_sum 

  def no_negative_quantity
    if  processed_quantity < 0 
      errors.add(:processed_quantity , "Total pengerjaan tidak boleh < 0" )  
    end
    
    if  ok_quantity < 0 
      errors.add(:ok_quantity , "Hasil yang sukses tidak boleh < 0 " )  
    end
    
    if  broken_quantity < 0 
      errors.add(:broken_quantity , "Hasil yang gagal tidak boleh < 0 " )  
    end
  end
  
  def matching_quantity_sum
    if broken_quantity + ok_quantity != processed_quantity
      errors.add(:processed_quantity , "Jumlah gagal dan sukses tidak sesuai dengan total pengerjaan" )  
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
    new_object.order_date         =  params[:order_date]
    new_object.finish_date        =  params[:finish_date]
    
    if new_object.save  
      sales_item.update_pre_production_statistics 
    end
    
    return new_object 
  end
end
