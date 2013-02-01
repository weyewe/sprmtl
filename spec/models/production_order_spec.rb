require 'spec_helper'

describe ProductionOrder do
  before(:each) do
    # @admin = FactoryGirl.create(:user, :email => "admin@gmail.com", :password => "willy1234", :password_confirmation => "willy1234")
    
    role = {
      :system => {
        :administrator => true
      }
    }

    Role.create!(
    :name        => ROLE_NAME[:admin],
    :title       => 'Administrator',
    :description => 'Role for administrator',
    :the_role    => role.to_json
    )
    @admin_role = Role.find_by_name ROLE_NAME[:admin]
    @admin =  User.create_main_user(   :email => "admin@gmail.com" ,:password => "willy1234", :password_confirmation => "willy1234") 
    
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
      :weight_per_piece   => '15',
      :name => "Sales Item",
      :is_pending_pricing    => false, 
      :is_pricing_by_weight  => false , 
      :pre_production_price  => "50000", 
      :production_price      => "20000",
      :post_production_price => "150000"
    })
  end
  
  context "checking sales order confirmation post condition on production order " do
    before(:each) do
      @quantity = 50 
       @has_production_sales_item = SalesItem.create_sales_item( @admin, @sales_order,  {
          :material_id => @copper.id, 
          :is_pre_production => true , 
          :is_production     => true, 
          :is_post_production => true, 
          :is_delivered => true, 
          :delivery_address => "Perumahan Citra Garden 1 Blok AC2/3G",
          :quantity => @quantity,
          :description => "Bla bla bla bla bla", 
          :delivery_address => "Yeaaah babyy", 
          :requested_deadline => Date.new(2013, 3,5 ),
          :weight_per_piece => "15",
          :name => "has Prod",
          :is_pending_pricing    => false, 
          :is_pricing_by_weight  => false , 
          :pre_production_price  => "50000", 
          :production_price      => "20000",
          :post_production_price => "150000"
        })
        @has_production_sales_item.reload  
        @initial_pending_production = @has_production_sales_item.pending_production 
        @sales_order.confirm(@admin)
        @sales_order.reload 
        @has_production_sales_item.reload  
    end
    
    it 'should confirm sales order and sales item' do
      @sales_order.is_confirmed.should be_true 
      @has_production_sales_item.is_confirmed.should be_true 
    end
    
    it 'should confirm if there is one  sales production order' do 
      @has_production_sales_item.production_orders.count.should == 1
      @has_production_sales_item.sales_production_orders.count.should == 1 
    end
    
    it 'should confirm the quantity of sales production order equals to the sales item quantity' do 
      @has_production_sales_item.sales_production_orders.first.quantity.should == @has_production_sales_item.quantity
    end
    
    it 'should increase the pending production for that item' do
      @final_pending_production = @has_production_sales_item.pending_production 
      diff = @final_pending_production - @initial_pending_production
      diff.should ==  @quantity
    end
    
    it 'should increase pending production for the subcription item' do 
      @sales_item_subcription = @has_production_sales_item.sales_item_subcription 
      @final_subcription_pending_production = @sales_item_subcription.pending_production   
      @final_subcription_pending_production.should == @quantity 
    end
  end 
end
