class PreProductionHistoriesController < ApplicationController
  before_filter :role_required, :except => [:generate_pre_production_history]
  
  def generate_pre_production_history
    @sales_item   =  SalesItem.find_by_id params[:selected_sales_item_id]
    @histories    = @sales_item.pre_production_histories.order("created_at DESC")
    @sales_order  = @sales_item.sales_order
    @new_object   = PreProductionHistory.new
  end
  
  def new
    # no idea about shite.. looking forward to get a sales item ID from you
    respond_to do |format|
      format.html {}
      format.js do 
        @parent = SalesItem.find_by_id params[:sales_item_id] 
        @new_object = PreProductionHistory.new
      end
    end
  end
  
  def create
    # HARD CODE.. just for testing purposes 
    # params[:customer][:town_id] = Town.first.id 
    
    params[:pre_production_history][:start_date] = parse_date( params[:pre_production_history][:start_date] )
    params[:pre_production_history][:finish_date] = parse_date( params[:pre_production_history][:finish_date] )
    @parent = SalesItem.find_by_id params[:sales_item_id] 
    @object = PreProductionHistory.create_history( current_user, @parent, params[:pre_production_history] ) 
    if @object.errors.size == 0 
      @new_object=  PreProductionHistory.new
    else
      @new_object= @object
    end
    
  end
   
  
  def edit
    # @customer = Customer.find_by_id params[:id] 
    
    
    @parent = SalesItem.find_by_id params[:sales_item_id] 
    @object = PreProductionHistory.find_by_id params[:id]
  end
  
  def update_pre_production_history
    params[:pre_production_history][:start_date] = parse_date( params[:pre_production_history][:start_date] )
    params[:pre_production_history][:finish_date] = parse_date( params[:pre_production_history][:finish_date] )
    
    
    @object = PreProductionHistory.find_by_id params[:pre_production_history_id] 
    @parent = @object.sales_item 
    @object.update_history( current_user, @parent,  params[:pre_production_history])
    @has_no_errors  = @object.errors.size  == 0
  end
  
  def delete_pre_production_history 
    @object = PreProductionHistory.find_by_id params[:object_to_destroy_id]
    @object_identifier = @object.created_at 
    @parent= @object.sales_item
    @object_id = @object.id 
    @object.delete(current_user ) 
  end
  
=begin
  CONFIRM SALES RELATED
=end
  def confirm_pre_production_history
    @pre_production_history = PreProductionHistory.find_by_id params[:pre_production_history_id]
    # add some defensive programming.. current user has role admin, and current_user is indeed belongs to the company 
    @pre_production_history.confirm( current_user  ) 
    @object =  @pre_production_history
    @parent = @object.sales_item 
  end
end

