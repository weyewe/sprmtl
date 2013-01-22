require 'spec_helper'

describe SalesOrder do
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
    
    context 'creating sales order with 1 sales item, including production' do
      before(:each) do
        @quantity_in_sales_item = 50 
        @has_production_sales_item = SalesItem.create_sales_item( @admin, @sales_order,  {
            :material_id => @copper.id, 
            :is_pre_production => true , 
            :is_production     => true, 
            :is_post_production => true, 
            :is_delivered => true, 
            :delivery_address => "Perumahan Citra Garden 1 Blok AC2/3G",
            :quantity => @quantity_in_sales_item,
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
      
      it 'should have 1 sales_item' do
        @sales_order.sales_items.count.should == 1 
      end
      
      it 'should be confirmable' do 
        @sales_order.confirm( @admin ) 
        @sales_order.is_confirmed.should be_true
      end
      
    end # context 'creating sales order with 1 sales item, including production'
  end
  
  
end
