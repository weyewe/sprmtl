class PaymentsController < ApplicationController
  before_filter :role_required
  def new
    @objects = Payment.order("created_at DESC") 
    @new_object = Payment.new 
    
    add_breadcrumb "Payment", 'new_payment_url'
  end
   
  
  def create 
    @object = Payment.create_by_employee( current_user, params[:payment] ) 
    if @object.errors.size == 0 
      @new_object=  Payment.new
    else
      @new_object= @object
    end
  end
   
    
  def edit
    # @customer = Customer.find_by_id params[:id] 
    @object = Payment.find_by_id params[:id]
  end
  
  def update_payment
    @object = Payment.find_by_id params[:payment_id] 
    @object.update_by_employee( current_user, params[:payment])
    @has_no_errors  = @object.errors.size  == 0
  end
  
  def delete_payment
    @object = Payment.find_by_id params[:object_to_destroy_id]
    @object.delete(current_user ) 
  end
  
=begin
  CONFIRM SALES RELATED
=end
  def confirm_payment
    @payment = Payment.find_by_id params[:payment_id]
    # add some defensive programming.. current user has role admin, and current_user is indeed belongs to the company 
    @payment.confirm( current_user  )  
  end

=begin
  PRINT SALES ORDER
=end
  def print_payment
    @payment = Payment.find_by_id params[:payment_id]
    puts "The invoce inspect: #{@invoice}\n"
    respond_to do |format|
      format.html # do
       #        pdf = SalesInvoicePdf.new(@sales_order, view_context)
       #        send_data pdf.render, filename:
       #        "#{@sales_order.printed_sales_invoice_code}.pdf",
       #        type: "application/pdf"
       #      end
      format.pdf do
        pdf = PaymentPdf.new(@payment, view_context,CONTINUOUS_FORM_WIDTH,FULL_CONTINUOUS_FORM_LENGTH)
        send_data pdf.render, filename:
        "#{@payment.printed_code}.pdf",
        type: "application/pdf"
      end
    end
  end
end
