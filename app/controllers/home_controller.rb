class HomeController < ApplicationController
  skip_before_filter :role_required,  :only => [:index, :show]
  
  def index
    @objects = SalesItem.joins(:sales_order => [:customer]).where{
      ( fulfilled_order.lt self.quantity )  & 
      ( is_confirmed.eq true )
    }.order("created_at ASC")
  end
end
