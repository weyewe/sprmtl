class SalesOrdersController < ApplicationController
  def new
    @objects = SalesOrder.active_objects 
    @new_object = SalesOrder.new 
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
  
  def update_sales_order
    @object = SalesOrder.find_by_id params[:sales_order_id] 
    @object.update_by_employee( current_user, params[:sales_order])
    @has_no_errors  = @object.errors.size  == 0
  end
  
  def delete_sales_order
    @object = SalesOrder.find_by_id params[:object_to_destroy_id]
    @object.delete 
  end
  
=begin
  CONFIRM SALES RELATED
=end
  def confirm_sales_order
    @sales_order = SalesOrder.find_by_id params[:sales_order_id]
    # add some defensive programming.. current user has role admin, and current_user is indeed belongs to the company 
    @sales_order.confirm( current_user  )  
  end
end
