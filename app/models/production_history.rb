class ProductionHistory < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :sales_item 
  
  def ProductionHistory.create_history( employee, sales_item , param ) 
    return nil if employee.nil?  or sales_item.nil? 
    
    new_object  = ProductionHistory.new
    
    
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
