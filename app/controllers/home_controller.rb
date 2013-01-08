class HomeController < ApplicationController
  skip_before_filter :role_required,  :only => [  
                                                :index,   
                                                :show,
                                                :production_details,
                                                :post_production_details,
                                                :delivery_entry_details
                                                ]
  
  def index
    @objects = SalesItem.joins(:sales_order => [:customer]).where{
      # ( fulfilled_order.lt self.quantity )  & 
      ( is_confirmed.eq true )
    }.order("created_at ASC")
    
    
    add_breadcrumb "Monitor Progress", 'root_url' 
  end
  
  def production_details
    extract_sales_item
    @objects = @sales_item.production_histories.where(:is_confirmed => true).order("created_at DESC")
    
    add_breadcrumb "Monitor Progress", 'root_url'
    set_breadcrumb_for @sales_item, 'production_details_url' + "(#{@sales_item.id})", 
                "Detail Produksi"
  end
  
  def post_production_details
    extract_sales_item
    @objects = @sales_item.post_production_histories.where(:is_confirmed => true).order("created_at DESC")
    
    add_breadcrumb "Monitor Progress", 'root_url'
    set_breadcrumb_for @sales_item, 'post_production_details_url' + "(#{@sales_item.id})", 
                "Detail Post Produksi"
  end
  
  def delivery_entry_details
    extract_sales_item
    @objects = @sales_item.delivery_entries.where(:is_confirmed => true).order("created_at DESC")
    
    add_breadcrumb "Monitor Progress", 'root_url'
    set_breadcrumb_for @sales_item, 'delivery_entry_details_url' + "(#{@sales_item.id})", 
                "Detail Delivery"
  end
  
  
  def extract_sales_item
    @sales_item = SalesItem.find_by_id params[:sales_item_id]
  end
end
