class SalesReturnEntriesController < ApplicationController
  before_filter :role_required
  
  def new
    @parent = SalesReturn.find_by_id params[:sales_return_id]
    @objects = @parent.sales_return_entries.joins(:delivery_entry => [:sales_item]) 
    @new_object = SalesReturnEntry.new 
    
    add_breadcrumb "Sales Return", 'new_sales_return_url'
    set_breadcrumb_for @parent, 'new_sales_return_sales_return_entry_url' + "(#{@parent.id})", 
                "Konfirmasi Sales Return Entry"
  end
  
  # def create
  #   # HARD CODE.. just for testing purposes 
  #   # params[:customer][:town_id] = Town.first.id 
  #   @parent = SalesReturn.find_by_id params[:sales_return_id]
  #   @object = SalesReturnEntry.create_sales_item( current_user, @parent, params[:sales_return_entry] ) 
  #   if @object.errors.size == 0 
  #     @new_object=  SalesReturnEntry.new
  #   else
  #     @new_object= @object
  #   end
  #   
  # end
  
  
   
  
  def edit
    # @customer = Customer.find_by_id params[:id] 
    @object = SalesReturnEntry.find_by_id params[:id]
     
  end
  
  def update_sales_return_entry
    @object = SalesReturnEntry.find_by_id params[:sales_return_entry_id] 
    @parent = @object.sales_return
    @object.update_return_handling(  params[:sales_return_entry])
    @has_no_errors  = @object.errors.size  == 0
  end
  
  # def delete_sales_item
  #   @object = SalesReturnEntry.find_by_id params[:object_to_destroy_id]
  #   @object.delete 
  # end
  
  
  # def search_sales_item
  #   search_params = params[:q]
  #   
  #   @objects = [] 
  #   query = '%' + search_params + '%'
  #   # on PostGre SQL, it is ignoring lower case or upper case 
  #   @objects = SalesReturnEntry.where{ (code =~ query)  & (is_deleted.eq false) }.map{|x| {:code => x.code, :id => x.id }}
  #   
  #   respond_to do |format|
  #     format.html # show.html.erb 
  #     format.json { render :json => @objects }
  #   end
  # end
end
