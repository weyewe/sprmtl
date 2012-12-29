require 'spec_helper'

describe SalesItem do
  before(:each) do
    @admin = FactoryGirl.create(:user, :email => "admin@gmail.com", :password => "willy1234", :password_confirmation => "willy1234")
  
    
    @customer = FactoryGirl.create(:customer,  :name => "Weyewe",
                                            :contact_person => "Willy" )  
                                            
    @sales_order   = SalesOrder.create_by_employee( @admin , {
      :customer_id    => @customer.id,          
      :payment_term   => PAYMENT_TERM[:cash],    
      :order_date     => Date.new(2012, 12, 15)   
    })
  end
   
     
  it 'should create sales item if ther ei admin and sales order' do 
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
  
  context "upon sales order confirmation" do
    before(:each) do 
      @has_production_sales_item = SalesItem.create_sales_item( @admin, @sales_order,  {
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
      
      @only_machining_sales_item = SalesItem.create_sales_item( @admin, @sales_order,  {
        :material_id => MATERIAL[:steel][:value], 
        :is_pre_production => true , 
        :is_production     => false, 
        :is_post_production => true, 
        :is_delivered => true, 
        :delivery_address => "Perumahan Citra Garden 1 Blok AC2/3G",
        :quantity => 15,
        :description => "Bla bla bla bla bla", 
        :delivery_address => "Yeaaah babyy", 
        :requested_deadline => Date.new(2013, 3,5 ),
        :price_per_piece => "80000",
      })
      @sales_order.confirm(@admin)
      @has_production_sales_item.reload
      @only_machining_sales_item.reload 
    end
    
    it 'should set the correct sales item classification' do
      @has_production_sales_item.only_machining?.should be_false 
      @has_production_sales_item.casting_included?.should be_true 
      
      @only_machining_sales_item.only_machining?.should be_true
      @only_machining_sales_item.casting_included?.should be_false 
    end
    
    it 'should have propagate the sales order confirmation to the sales item' do
      @has_production_sales_item.is_confirmed.should be_true 
      @only_machining_sales_item.is_confirmed.should be_true 
    end
    
    it 'should produce 1 production order for those including production phase' do
      ProductionOrder.count.should == 1 
      PostProductionOrder.count.should == 1 
      @has_production_sales_item.production_orders.count.should == 1 
      @has_production_sales_item.post_production_orders.count.should == 0 
      
      @only_machining_sales_item.production_orders.count.should == 0 
      @only_machining_sales_item.post_production_orders.count.should == 1 
    end
  end
  
end