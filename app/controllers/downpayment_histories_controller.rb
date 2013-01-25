class DownpaymentHistoriesController < ApplicationController
  def index
    @customer = Customer.find_by_id params[:customer_id]
    @objects  = @customer.downpayment_histories.joins(:payment).order("created_at DESC")
    add_breadcrumb "Monitor Hutang", 'customers_with_outstanding_payment_url' 
    set_breadcrumb_for @customer, 'customer_downpayment_histories_url' + "(#{@customer.id})", 
                "Sejarah DP: penggunaan dan penambahan"
  end
end
