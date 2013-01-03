class DeliveryEntriesController < ApplicationController
  def new
    @parent = Delivery.find_by_id params[:delivery_id]
    @customer = @parent.customer 
    @objects = @parent.delivery_entries 
    @new_object = DeliveryEntry.new 
  end
  
  def create
    # HARD CODE.. just for testing purposes 
    # params[:customer][:town_id] = Town.first.id 
    @parent = Delivery.find_by_id params[:delivery_id]
    @object = DeliveryEntry.create_delivery_entry( current_user, @parent, params[:delivery_entry] ) 
    @customer = @parent.customer
    if @object.errors.size == 0 
      @new_object=  DeliveryEntry.new
    else
      @new_object= @object
    end
    
  end 
  
  def edit
    # @customer = Customer.find_by_id params[:id] 
    @object = DeliveryEntry.find_by_id params[:id]
    @parent = @object.delivery
    @customer = @parent.customer 
  end
  
  def update_delivery_entry
    @object = DeliveryEntry.find_by_id params[:delivery_entry_id] 
    @parent = @object.delivery
    @object.update_delivery_entry(current_user, @parent,   params[:delivery_entry])
    @customer = @parent.customer
    @has_no_errors  = @object.errors.size  == 0
  end
  
  def delete_delivery_entry
    @object = DeliveryEntry.find_by_id params[:object_to_destroy_id]
    @object.delete(current_user)
  end
  
  
  def search_delivery_entry
    search_params = params[:q]
    
    @objects = [] 
    query = '%' + search_params + '%'
    # on PostGre SQL, it is ignoring lower case or upper case 
    @objects = DeliveryEntry.where{ (code =~ query)  & (is_deleted.eq false) }.map{|x| {:code => x.code, :id => x.id }}
    
    respond_to do |format|
      format.html # show.html.erb 
      format.json { render :json => @objects }
    end
  end
end
