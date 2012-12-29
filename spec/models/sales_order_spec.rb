require 'spec_helper'

describe SalesOrder do
  before(:each) do
    @admin = FactoryGirl.create(:user, :email => "admin@gmail.com", :password => "willy1234", :password_confirmation => "willy1234")
  
    
    @customer = FactoryGirl.create(:customer,  :name => "Weyewe",
                                            :contact_person => "Willy" )  
  end
  
  it 'should have 1 custumer' do
    @customer.should be_valid 
  end
  
  it 'should not allow sales order creation if there is no employee' do 
    sales_order   = SalesOrder.create_by_employee( nil , {
      :customer_id    => @customer.id,          
      :payment_term   => PAYMENT_TERM[:cash],    
      :order_date     => Date.new(2012, 12, 15)   
    })
    
    sales_order.should be_nil 
  end
  
  it 'should allow creation if there is employee' do
    sales_order   = SalesOrder.create_by_employee( @admin , {
      :customer_id    => @customer.id,          
      :payment_term   => PAYMENT_TERM[:cash],    
      :order_date     => Date.new(2012, 12, 15)   
    })
    
    sales_order.should be_valid
  end
  
  context "post sales order creation" do
    before(:each) do
      @sales_order   = SalesOrder.create_by_employee( @admin , {
        :customer_id    => @customer.id,          
        :payment_term   => PAYMENT_TERM[:cash],    
        :order_date     => Date.new(2012, 12, 15)   
      })
    end
    
    it 'should not be confirmable if there is no sales item' do
      @sales_order.confirm( @admin ) 
      @sales_order.is_confirmed.should be_false 
    end
    
    it 'should confirm if there is one sales item' do
      
      
      sales_item_1 = SalesItem.create_sales_item( @admin, @sales_order,  {
        :material_id => MATERIAL[:steel][:value], 
        :is_pre_production => true , 
        :is_production     => true, 
        :is_post_production => true, 
        :is_delivered => true, 
        :delivery_address => "Perumahan Citra Garden 1 Blok AC2/3G",
        :quantity => 50,
        :description => "Bla bla bla bla bla", 
        :delivery_address => "Yeaaah babyy", 
        :requested_deadline => Date.new(2013, 3,5 ),
        :price_per_piece => "90000",
      })
      
      @sales_order.confirm(@admin)
      @sales_order.is_confirmed.should be_true  
    end
  end
  
  
end
