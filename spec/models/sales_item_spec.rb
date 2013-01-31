require 'spec_helper'

describe SalesItem do
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
  end
   
     
  it 'should create sales item if ther ei admin and sales order' do 
    sales_item_1 = SalesItem.create_sales_item( @admin, @sales_order,  {
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
    
    @sales_order.sales_items.count.should == 1
    
    @sales_order.confirm(@admin)
    @sales_order.is_confirmed.should be_true  
  end 
  
  context "upon sales order confirmation" do
    before(:each) do 
      @has_production_quantity = 50 
      @has_production_sales_item = SalesItem.create_sales_item( @admin, @sales_order,  {
        :material_id => @copper.id, 
        :is_pre_production => true , 
        :is_production     => true, 
        :is_post_production => true, 
        :is_delivered => true, 
        :delivery_address => "Perumahan Citra Garden 1 Blok AC2/3G",
        :quantity => @has_production_quantity,
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
      
      @only_machining_sales_item = SalesItem.create_sales_item( @admin, @sales_order,  {
        :material_id => @copper.id, 
        :is_pre_production => true , 
        :is_production     => false, 
        :is_post_production => true, 
        :is_delivered => true, 
        :delivery_address => "Perumahan Citra Garden 1 Blok AC2/3G",
        :quantity => 15,
        :description => "Bla bla bla bla bla", 
        :delivery_address => "Yeaaah babyy", 
        :requested_deadline => Date.new(2013, 3,5 ),
        :weight_per_piece   => '15',
        :name => "has Prod",
        :is_pending_pricing    => false, 
        :is_pricing_by_weight  => false , 
        :pre_production_price  => "50000", 
        :production_price      => "20000",
        :post_production_price => "150000"
      })
      
      @initial_has_production_pending_production = @has_production_sales_item.pending_production
      @sales_order.confirm(@admin)
     
      @has_production_sales_item.reload
      @only_machining_sales_item.reload 
    end
    
    
    it 'should have id' do
      @has_production_sales_item.id.should_not be_nil 
    end
    
    it 'should be linked to the customer' do
      @has_production_sales_item.customer.should be_valid 
    end
    
    it 'should create sales_item_subcription' do
      sales_item_subcription = @has_production_sales_item.sales_item_subcription
      sales_item_subcription.customer_id.should == @customer.id 
    end
    
    it 'should create abstract sales item'  do
      template_sales_item = @has_production_sales_item.template_sales_item
      template_sales_item.should be_valid 
      template_sales_item.code.should == @has_production_sales_item.code 
    end
    
    it 'should link production order with sales_item_subcription + abstract_sales_item' do
      production_order = @has_production_sales_item.production_orders.first 
      production_order.template_sales_item_id.should == @has_production_sales_item.template_sales_item_id 
      production_order.sales_item_subcription_id.should == @has_production_sales_item.sales_item_subcription_id 
    end
    
    it 'should not allow only_machining' do
      @only_machining_sales_item.only_machining?.should be_true 
      @only_machining_sales_item.is_production?.should be_false 
    end
    
    it 'should have propagate the sales order confirmation to the sales item' do
      @has_production_sales_item.is_confirmed.should be_true 
      @only_machining_sales_item.is_confirmed.should be_true 
    end
    
    it 'should produce 1 production order for those including production phase' do
      ProductionOrder.count.should == 1 
      PostProductionOrder.count.should == 0 
      @has_production_sales_item.production_orders.count.should == 1 
      @has_production_sales_item.post_production_orders.count.should == 0 
      
      @only_machining_sales_item.production_orders.count.should == 0 
      @only_machining_sales_item.post_production_orders.count.should == 0
    end
    
    it 'should update the pending_production' do
      @final_has_production_pending_production = @has_production_sales_item.pending_production
      
      delta = @final_has_production_pending_production - @initial_has_production_pending_production
      # 
      # puts "initial_pending_production: #{@initial_has_production_pending_production}"
      # puts "final_has_production_pending_production: #{@final_has_production_pending_production}"
      delta.should == @has_production_quantity
    end
  end # on confirming sales order 
  
  
  
end
