class SalesItemsController < ApplicationController
  before_filter :role_required, :except => [:search_sales_item]
  def new
    @parent = SalesOrder.find_by_id params[:sales_order_id]
    @objects = @parent.active_sales_items 
    @new_object = SalesItem.new 
  end
  
  def create
    # HARD CODE.. just for testing purposes 
    # params[:customer][:town_id] = Town.first.id 
    @parent = SalesOrder.find_by_id params[:sales_order_id]
    @object = SalesItem.create_sales_item( current_user, @parent, params[:sales_item] ) 
    if @object.errors.size == 0 
      @new_object=  SalesItem.new
    else
      @new_object= @object
    end
    
  end
  
  
   
  
  def edit
    # @customer = Customer.find_by_id params[:id] 
    @object = SalesItem.find_by_id params[:id]
  end
  
  def update_sales_item
    @object = SalesItem.find_by_id params[:sales_item_id] 
    @parent = @object.sales_order
    @object.update_sales_item(  params[:sales_item])
    @has_no_errors  = @object.errors.size  == 0
  end
  
  def delete_sales_item
    @object = SalesItem.find_by_id params[:object_to_destroy_id]
    @object.delete 
  end
  
  
  def search_sales_item
    search_params = params[:q]
    
    @objects = [] 
    query = '%' + search_params + '%'
    # on PostGre SQL, it is ignoring lower case or upper case 
    @objects = SalesItem.where{ (code =~ query)  &
                      (is_deleted.eq false) & 
                      (is_confirmed.eq true) }.map{|x| {:code => x.code, :id => x.id }}
    
    respond_to do |format|
      format.html # show.html.erb 
      format.json { render :json => @objects }
    end
  end
end
