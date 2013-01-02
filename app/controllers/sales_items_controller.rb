class SalesItemsController < ApplicationController
  def new
    @parent = SalesOrder.find_by_id params[:sales_order_id]
    @objects = @parent.active_sales_items 
    @new_object = SalesItem.new 
  end
  
  def create
    # HARD CODE.. just for testing purposes 
    # params[:customer][:town_id] = Town.first.id 
    
    @object = SalesOrder.create_by_employee( current_user, params[:sales_order] ) 
    if @object.errors.size == 0 
      @new_object=  SalesOrder.new
    else
      @new_object= @object
    end
    
  end
  
   
  
  def edit
    # @customer = Customer.find_by_id params[:id] 
    @object = SalesOrder.find_by_id params[:id]
  end
  
  def update_sales_item
    @object = SalesOrder.find_by_id params[:sales_order_id] 
    @object.update_by_employee( current_user, params[:sales_order])
    @has_no_errors  = @object.errors.size  == 0
  end
  
  def delete_sales_item
    @object = SalesOrder.find_by_id params[:object_to_destroy_id]
    @object.delete 
  end
end
