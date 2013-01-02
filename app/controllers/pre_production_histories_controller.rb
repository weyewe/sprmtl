class PreProductionHistoriesController < ApplicationController
  def new
    # no idea about shite.. looking forward to get a sales item ID from you
  end
  
  def create
    # HARD CODE.. just for testing purposes 
    # params[:customer][:town_id] = Town.first.id 
    
    @object = PreProductionHistory.create_by_employee( current_user, params[:pre_production_history] ) 
    if @object.errors.size == 0 
      @new_object=  PreProductionHistory.new
    else
      @new_object= @object
    end
    
  end
   
  
  def edit
    # @customer = Customer.find_by_id params[:id] 
    @object = PreProductionHistory.find_by_id params[:id]
  end
  
  def update_pre_production_history
    @object = PreProductionHistory.find_by_id params[:pre_production_history_id] 
    @object.update_by_employee( current_user, params[:pre_production_history])
    @has_no_errors  = @object.errors.size  == 0
  end
  
  def delete_pre_production_history 
    @object = PreProductionHistory.find_by_id params[:object_to_destroy_id]
    @object.delete 
  end
  
=begin
  CONFIRM SALES RELATED
=end
  def confirm_pre_production_history
    @pre_production_history = PreProductionHistory.find_by_id params[:pre_production_history_id]
    # add some defensive programming.. current user has role admin, and current_user is indeed belongs to the company 
    @pre_production_history.confirm( current_user  )  
  end
end

