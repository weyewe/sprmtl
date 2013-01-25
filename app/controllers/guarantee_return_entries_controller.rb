class GuaranteeReturnEntriesController < ApplicationController
  before_filter :role_required 
  
  def new
    @parent = GuaranteeReturn.find_by_id params[:guarantee_return_id]
    @customer = @parent.customer 
    @objects = @parent.guarantee_return_entries 
    @new_object = GuaranteeReturnEntry.new 
    
    add_breadcrumb "Garansi Retur", 'new_guarantee_return_url'
    set_breadcrumb_for @parent, 'new_guarantee_return_guarantee_return_entry_url' + "(#{@parent.id})", 
                "Tambah  Item ke Garansi Retur"
  end
  
  def create
    # HARD CODE.. just for testing purposes 
    # params[:customer][:town_id] = Town.first.id 
    @parent = GuaranteeReturn.find_by_id params[:guarantee_return_id]
    @object = GuaranteeReturnEntry.create_guarantee_return_entry( current_user, @parent, params[:guarantee_return_entry] ) 
    @customer = @parent.customer
    if @object.errors.size == 0 
      @new_object=  GuaranteeReturnEntry.new
    else
      @new_object= @object
    end
    
  end 
  
  def edit
    # @customer = Customer.find_by_id params[:id] 
    @object = GuaranteeReturnEntry.find_by_id params[:id]
    @parent = @object.guarantee_return
    @customer = @parent.customer 
  end
  
  def update_guarantee_return_entry
    @object = GuaranteeReturnEntry.find_by_id params[:guarantee_return_entry_id] 
    @parent = @object.guarantee_return
    @object.update_guarantee_return_entry(current_user, @parent,   params[:guarantee_return_entry])
    @customer = @parent.customer
    @has_no_errors  = @object.errors.size  == 0
  end
  
  def delete_guarantee_return_entry
    @object = GuaranteeReturnEntry.find_by_id params[:object_to_destroy_id]
    @object.delete(current_user)
  end
  
  
  # 
  # 
  # def edit_post_guarantee_return_guarantee_return_entry
  #   @object = GuaranteeReturnEntry.find_by_id params[:guarantee_return_entry_id]
  #   @parent = @object.guarantee_return 
  #   
  # end
  # 
  # def update_post_guarantee_return_guarantee_return_entry
  #   @object = GuaranteeReturnEntry.find_by_id params[:guarantee_return_entry_id]
  #   @parent = @object.guarantee_return
  #   
  #   @object.update_post_guarantee_return( current_user, params[:guarantee_return_entry] )
  #   @customer = @parent.customer
  #   @has_no_errors  = @object.errors.size  == 0
  # end
end

