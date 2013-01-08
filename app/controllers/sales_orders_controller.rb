class SalesOrdersController < ApplicationController
  before_filter :role_required
  def new
    @objects = SalesOrder.active_objects 
    @new_object = SalesOrder.new 
    
    add_breadcrumb "Sales Order", 'new_sales_order_url'
  end
  
  def create
    # HARD CODE.. just for testing purposes 
    # params[:customer][:town_id] = Town.first.id 
    
    @object = SalesOrder.create_by_employee( current_user, params[:sales_order] ) 
    if @object.errors.size == 0 
      @new_object=  SalesOrder.new
    else
      @new_object= @object
    end
    
  end
  
   
  
  def edit
    # @customer = Customer.find_by_id params[:id] 
    @object = SalesOrder.find_by_id params[:id]
  end
  
  def update_sales_order
    @object = SalesOrder.find_by_id params[:sales_order_id] 
    @object.update_by_employee( current_user, params[:sales_order])
    @has_no_errors  = @object.errors.size  == 0
  end
  
  def delete_sales_order
    @object = SalesOrder.find_by_id params[:object_to_destroy_id]
    @object.delete(current_user) 
  end
  
=begin
  CONFIRM SALES RELATED
=end
  def confirm_sales_order
    @sales_order = SalesOrder.find_by_id params[:sales_order_id]
    # add some defensive programming.. current user has role admin, and current_user is indeed belongs to the company 
    @sales_order.confirm( current_user  )  
  end
  
=begin
  PRINT SALES ORDER
=end
  def print_sales_order
    @sales_order = SalesOrder.find_by_id params[:sales_order_id]
    respond_to do |format|
      format.html # do
       #        pdf = SalesInvoicePdf.new(@sales_order, view_context)
       #        send_data pdf.render, filename:
       #        "#{@sales_order.printed_sales_invoice_code}.pdf",
       #        type: "application/pdf"
       #      end
      format.pdf do
        pdf = SalesOrderPdf.new(@sales_order, view_context,CONTINUOUS_FORM_WIDTH,FULL_CONTINUOUS_FORM_LENGTH)
        send_data pdf.render, filename:
        "#{@sales_order.printed_sales_invoice_code}.pdf",
        type: "application/pdf"
      end
    end
  end
end
