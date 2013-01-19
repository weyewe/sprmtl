class SalesReturnsController < ApplicationController
  before_filter :role_required
  def new
    @objects = SalesReturn.joins(:delivery).order("created_at DESC") 
    add_breadcrumb "Sales Return", 'new_sales_return_url'
    # @new_object = SalesOrder.new 
  end
  
  # def create
  #   # HARD CODE.. just for testing purposes 
  #   # params[:customer][:town_id] = Town.first.id 
  #   
  #   @object = SalesOrder.create_by_employee( current_user, params[:sales_order] ) 
  #   if @object.errors.size == 0 
  #     @new_object=  SalesOrder.new
  #   else
  #     @new_object= @object
  #   end
  # end
  
   
  
  # def edit
  #   # @customer = Customer.find_by_id params[:id] 
  #   @object = SalesOrder.find_by_id params[:id]
  # end
  
  # def update_sales_order
  #   @object = SalesOrder.find_by_id params[:sales_order_id] 
  #   @object.update_by_employee( current_user, params[:sales_order])
  #   @has_no_errors  = @object.errors.size  == 0
  # end
  
  # def delete_sales_order
  #   @object = SalesOrder.find_by_id params[:object_to_destroy_id]
  #   @object.delete 
  # end
  
=begin
  CONFIRM SALES RELATED
=end
  def confirm_sales_return
    @sales_return = SalesReturn.find_by_id params[:sales_return_id]
    # add some defensive programming.. current user has role admin, and current_user is indeed belongs to the company 
    @sales_return.confirm( current_user  )
    @sales_return.reload 
    # sleep 5  
  end
end
