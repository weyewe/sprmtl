class InvoicePaymentsController < ApplicationController
  before_filter :role_required
  def new
    @parent = Payment.find_by_id params[:payment_id]
    @customer = @parent.customer 
    @objects = @parent.invoice_payments.order("created_at DESC") 
    @new_object = InvoicePayment.new 
    
    add_breadcrumb "Payment", 'new_payment_url'
    set_breadcrumb_for @parent, 'new_payment_invoice_payment_url' + "(#{@parent.id})", 
                "Tambah Invoice ke Payment"
  end
  
  def create
    # HARD CODE.. just for testing purposes 
    # params[:customer][:town_id] = Town.first.id 
    @parent = Payment.find_by_id params[:payment_id]
    @customer = @parent.customer 
    @object = InvoicePayment.create_invoice_payment( current_user, @parent, params[:invoice_payment] ) 
    if @object.errors.size == 0 
      @new_object=  InvoicePayment.new
    else
      @new_object= @object
    end
    
  end
  
  
   
  
  def edit
    # @customer = Customer.find_by_id params[:id] 
    @object = InvoicePayment.find_by_id params[:id]
    @parent = @object.payment 
    @customer = @parent.customer 
  end
  
  def update_invoice_payment
    @object = InvoicePayment.find_by_id params[:invoice_payment_id] 
    @parent = @object.payment
    
    puts "The parent_id #{ @parent.id}\n"*10
    @customer = @parent.customer 
    @object.update_invoice_payment(  current_user, @parent , params[:invoice_payment])
    @has_no_errors  = @object.errors.size  == 0
  end
  
  def delete_invoice_payment
    @object = InvoicePayment.find_by_id params[:object_to_destroy_id]
    @object_identifier = @object.invoice.code 
    @object.delete(current_user )
  end
  
  
  def search_invoice_payment
    search_params = params[:q]
    
    @objects = [] 
    query = '%' + search_params + '%'
    # on PostGre SQL, it is ignoring lower case or upper case 
    @objects = InvoicePayment.where{ (code =~ query)  & (is_deleted.eq false) }.map{|x| {:code => x.code, :id => x.id }}
    
    respond_to do |format|
      format.html # show.html.erb 
      format.json { render :json => @objects }
    end
  end
end

