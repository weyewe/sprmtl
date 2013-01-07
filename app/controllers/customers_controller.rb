class CustomersController < ApplicationController
  before_filter :role_required, :except => [:search_customer]
  def new
    @objects = Customer.active_objects
    @new_object = Customer.new 
  end
  
  def create
    # HARD CODE.. just for testing purposes 
    # params[:customer][:town_id] = Town.first.id 
    @object = Customer.create( params[:customer] ) 
    if @object.valid?
      @new_object=  Customer.new
    else
      @new_object= @object
    end
    
  end
  
  def search_customer
    search_params = params[:q]
    
    @objects = [] 
    query = '%' + search_params + '%'
    # on PostGre SQL, it is ignoring lower case or upper case 
    @objects = Customer.where{ (name =~ query)  & (is_deleted.eq false) }.map{|x| {:name => x.name, :id => x.id }}
    
    respond_to do |format|
      format.html # show.html.erb 
      format.json { render :json => @objects }
    end
  end
  
  def edit
    @customer = Customer.find_by_id params[:id] 
  end
  
  def update_customer
    @customer = Customer.find_by_id params[:customer_id] 
    @customer.update_attributes( params[:customer])
    @has_no_errors  = @customer.errors.messages.length == 0
  end
  
  def delete_customer
    @customer = Customer.find_by_id params[:object_to_destroy_id]
    @customer.delete 
  end
end
