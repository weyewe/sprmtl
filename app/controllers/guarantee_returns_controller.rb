class GuaranteeReturnsController < ApplicationController
  before_filter :role_required
  
  def new
    @objects = GuaranteeReturn.order("created_at DESC")
    @new_object = GuaranteeReturn.new 
    add_breadcrumb "Guarantee Return", 'new_guarantee_return_url'
  end
  
  def create
    # HARD CODE.. just for testing purposes 
    # params[:customer][:town_id] = Town.first.id 
    
    params[:guarantee_return][:receival_date] = parse_date( params[:guarantee_return][:receival_date] )
    @object = GuaranteeReturn.create_by_employee( current_user, params[:guarantee_return] ) 
    if @object.errors.size == 0 
      @new_object=  GuaranteeReturn.new
    else
      @new_object= @object
    end
    
  end
  
  
  
  def edit
    # @customer = Customer.find_by_id params[:id] 
    @object = GuaranteeReturn.find_by_id params[:id]
  end
  
  def update_guarantee_return
    params[:guarantee_return][:receival_date] = parse_date( params[:guarantee_return][:receival_date] )
    @object = GuaranteeReturn.find_by_id params[:guarantee_return_id] 
    @object.update_by_employee( current_user, params[:guarantee_return])
    @has_no_errors  = @object.errors.size  == 0
  end
  
  def delete_guarantee_return
    @object = GuaranteeReturn.find_by_id params[:object_to_destroy_id]
    @object_identifier = @object.code 
    @object.delete(current_user) 
  end
  
=begin
  CONFIRM SALES RELATED
=end
  def confirm_guarantee_return
    @guarantee_return = GuaranteeReturn.find_by_id params[:guarantee_return_id]
    # add some defensive programming.. current user has role admin, and current_user is indeed belongs to the company 
    @guarantee_return.confirm( current_user  )  
    @guarantee_return.reload
  end
  
  # def finalize_guarantee_return
  #   @guarantee_return = GuaranteeReturn.find_by_id params[:guarantee_return_id]
  #   # add some defensive programming.. current user has role admin, and current_user is indeed belongs to the company
  #   # sleep 3 
  #   @guarantee_return.finalize( current_user  )
  #   @guarantee_return.reload
  # end
  
# =begin
#   PRINT SALES ORDER
# =end
#   def print_guarantee_return
#     @guarantee_return = GuaranteeReturn.find_by_id params[:guarantee_return_id]
#     respond_to do |format|
#       format.html # do
#        #        pdf = SalesInvoicePdf.new(@sales_order, view_context)
#        #        send_data pdf.render, filename:
#        #        "#{@sales_order.printed_sales_invoice_code}.pdf",
#        #        type: "application/pdf"
#        #      end
#       format.pdf do
#         pdf = GuaranteeReturnOrderPdf.new(@guarantee_return, view_context,CONTINUOUS_FORM_WIDTH,FULL_CONTINUOUS_FORM_LENGTH)
#         send_data pdf.render, filename:
#         "#{@guarantee_return.printed_code}.pdf",
#         type: "application/pdf"
#       end
#     end
#   end
end
