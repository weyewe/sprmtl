class PaymentsController < ApplicationController
  def new
    @objects = Payment.order("created_at DESC") 
    @new_object = Payment.new 
  end
  
  def create
    # HARD CODE.. just for testing purposes 
    # params[:customer][:town_id] = Town.first.id 
    
    @object = Payment.create_by_employee( current_user, params[:payment] ) 
    if @object.errors.size == 0 
      @new_object=  Payment.new
    else
      @new_object= @object
    end
    
  end
  
   
  
  def edit
    # @customer = Customer.find_by_id params[:id] 
    @object = Payment.find_by_id params[:id]
  end
  
  def update_payment
    @object = Payment.find_by_id params[:payment_id] 
    @object.update_by_employee( current_user, params[:payment])
    @has_no_errors  = @object.errors.size  == 0
  end
  
  def delete_payment
    @object = Payment.find_by_id params[:object_to_destroy_id]
    @object.delete(current_user ) 
  end
  
=begin
  CONFIRM SALES RELATED
=end
  def confirm_payment
    @payment = Payment.find_by_id params[:payment_id]
    # add some defensive programming.. current user has role admin, and current_user is indeed belongs to the company 
    @payment.confirm( current_user  )  
  end
end
