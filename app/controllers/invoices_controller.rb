class InvoicesController < ApplicationController
  before_filter :role_required
  def new
    @objects = Invoice.joins(:delivery => [:customer]).order("created_at DESC") 
    @new_object = Invoice.new 
  end
  
  # def create
  #   # HARD CODE.. just for testing purposes 
  #   # params[:customer][:town_id] = Town.first.id 
  #   
  #   @object = Invoice.create_by_employee( current_user, params[:invoice] ) 
  #   if @object.errors.size == 0 
  #     @new_object=  Invoice.new
  #   else
  #     @new_object= @object
  #   end
  #   
  # end
  
   
  
  def edit
    # @customer = Customer.find_by_id params[:id] 
    @object = Invoice.find_by_id params[:id]
  end
  
  def update_invoice
    @object = Invoice.find_by_id params[:invoice_id] 
    
    due_date =  parse_date(params[:invoice][:due_date])
    @object.update_due_date( current_user, due_date )
    @has_no_errors  = @object.errors.size  == 0
  end

  # def delete_invoice
  #   @object = Invoice.find_by_id params[:object_to_destroy_id]
  #   @object.delete 
  # end
  
=begin
  CONFIRM SALES RELATED
=end
  def confirm_invoice
    @invoice = Invoice.find_by_id params[:invoice_id]
    # add some defensive programming.. current user has role admin, and current_user is indeed belongs to the company 
    @invoice.confirm( current_user  )  
    @object =  @invoice
  end

=begin
  PRINT SALES ORDER
=end
  def print_invoice
    @invoice = Invoice.find_by_id params[:invoice_id]
    puts "The invoce inspect: #{@invoice}\n"
    respond_to do |format|
      format.html # do
       #        pdf = SalesInvoicePdf.new(@sales_order, view_context)
       #        send_data pdf.render, filename:
       #        "#{@sales_order.printed_sales_invoice_code}.pdf",
       #        type: "application/pdf"
       #      end
      format.pdf do
        pdf = InvoicePdf.new(@invoice, view_context,CONTINUOUS_FORM_WIDTH,FULL_CONTINUOUS_FORM_LENGTH)
        send_data pdf.render, filename:
        "#{@invoice.printed_code}.pdf",
        type: "application/pdf"
      end
    end
  end
end
