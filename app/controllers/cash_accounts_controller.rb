class CashAccountsController < ApplicationController
  before_filter :role_required
  def new
    @objects = CashAccount.order("created_at DESC")
    @new_object = CashAccount.new 
  end
  
  def create
    # HARD CODE.. just for testing purposes 
    # params[:customer][:town_id] = Town.first.id 
    @object = CashAccount.create( params[:cash_account] ) 
    if @object.valid?
      @new_object=  CashAccount.new
    else
      @new_object= @object
    end
    
  end
   
  
  def edit
    @object = CashAccount.find_by_id params[:id] 
  end
  
  def update_cash_account
    @object = CashAccount.find_by_id params[:cash_account_id] 
    @object.update_attributes( params[:cash_account])
    @has_no_errors  = @object.errors.messages.length == 0
  end
  
  def delete_cash_account
    @object = CashAccount.find_by_id params[:object_to_destroy_id]
    @object_identifier = @object.name  
    @object.delete(current_user )
  end
end
