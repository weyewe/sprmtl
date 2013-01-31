class ItemReceivalEntriesController < ApplicationController
  before_filter :role_required 
  
  def new
    @parent = ItemReceival.find_by_id params[:item_receival_id]
    @customer = @parent.customer 
    @objects = @parent.item_receival_entries 
    @new_object = ItemReceivalEntry.new 
    
    add_breadcrumb "Garansi Retur", 'new_item_receival_url'
    set_breadcrumb_for @parent, 'new_item_receival_item_receival_entry_url' + "(#{@parent.id})", 
                "Tambah  Item ke Penerimaan Bubut"
  end
  
  def create
    # HARD CODE.. just for testing purposes 
    # params[:customer][:town_id] = Town.first.id 
    @parent = ItemReceival.find_by_id params[:item_receival_id]
    @object = ItemReceivalEntry.create_item_receival_entry( current_user, @parent, params[:item_receival_entry] ) 
    @customer = @parent.customer
    if @object.errors.size == 0 
      @new_object=  ItemReceivalEntry.new
    else
      @new_object= @object
    end
    
  end 
  
  def edit
    # @customer = Customer.find_by_id params[:id] 
    @object = ItemReceivalEntry.find_by_id params[:id]
    @parent = @object.item_receival
    @customer = @parent.customer 
  end
  
  def update_item_receival_entry
    @object = ItemReceivalEntry.find_by_id params[:item_receival_entry_id] 
    @parent = @object.item_receival
    @object.update_item_receival_entry(current_user, @parent,   params[:item_receival_entry])
    @customer = @parent.customer
    @has_no_errors  = @object.errors.size  == 0
  end
  
  def delete_item_receival_entry
    @object = ItemReceivalEntry.find_by_id params[:object_to_destroy_id]
    @object.delete(current_user)
  end
  
  
  # 
  # 
  # def edit_post_item_receival_item_receival_entry
  #   @object = ItemReceivalEntry.find_by_id params[:item_receival_entry_id]
  #   @parent = @object.item_receival 
  #   
  # end
  # 
  # def update_post_item_receival_item_receival_entry
  #   @object = ItemReceivalEntry.find_by_id params[:item_receival_entry_id]
  #   @parent = @object.item_receival
  #   
  #   @object.update_post_item_receival( current_user, params[:item_receival_entry] )
  #   @customer = @parent.customer
  #   @has_no_errors  = @object.errors.size  == 0
  # end
end

