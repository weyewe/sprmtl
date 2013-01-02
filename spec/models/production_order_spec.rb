require 'spec_helper'

describe ProductionOrder do
  before(:each) do
    @admin = FactoryGirl.create(:user, :email => "admin@gmail.com", :password => "willy1234", :password_confirmation => "willy1234")
  
    @copper = Material.create :name => MATERIAL[:copper]
    @customer = FactoryGirl.create(:customer,  :name => "Weyewe",
                                            :contact_person => "Willy" )
                                            
    @sales_order   = SalesOrder.create_by_employee( @admin , {
      :customer_id    => @customer.id,          
      :payment_term   => PAYMENT_TERM[:cash],    
      :order_date     => Date.new(2012, 12, 15)   
    })
    
    @sales_item_1 = SalesItem.create_sales_item( @admin, @sales_order,  {
      :material_id => @copper.id, 
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
      :weight_per_piece   => '15',
      :name => "Sales Item"
    })
  end
  
  context "checking sales order confirmation post condition on production order " do
    before(:each) do
       @has_production_sales_item = SalesItem.create_sales_item( @admin, @sales_order,  {
          :material_id => @copper.id, 
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
          :weight_per_piece => "15",
          :name => "has Prod"
        })

        @sales_order.confirm(@admin)
    end
    
    it 'should confirm if there is one  sales production order' do 
      @has_production_sales_item.production_orders.count.should == 1
      @has_production_sales_item.sales_production_orders.count.should == 1 
    end
    
    it 'should confirm the quantity of sales production order equals to the sales item quantity' do 
      @has_production_sales_item.sales_production_orders.first.quantity.should == @has_production_sales_item.quantity
    end
  end 
end
