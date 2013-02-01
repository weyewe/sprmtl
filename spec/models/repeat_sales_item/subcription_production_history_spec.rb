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
    
    @has_production_quantity = 50 
    @has_production_sales_item = SalesItem.create_sales_item( @admin, @sales_order,  {
      :material_id => @copper.id, 
      :is_pre_production => true , 
      :is_production     => true, 
      :is_post_production => false, 
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
    
    @sales_order.confirm(@admin)
    @has_production_sales_item.reload 
    @sales_order.reload 
  end
  
  it 'should confirm sales order' do
    @sales_order.is_confirmed.should be_true 
  end
  
  context "creating repeat sales order" do
    before(:each) do
      @second_sales_order   = SalesOrder.create_by_employee( @admin , {
        :customer_id    => @customer.id,          
        :payment_term   => PAYMENT_TERM[:cash],    
        :order_date     => Date.new(2012, 12, 15)   
      })

      @repeat_quantity = 20 
      
      @initial_template_sales_item_count = TemplateSalesItem.count 
      
      @repeat_si = SalesItem.create_repeat_sales_item(@admin, @second_sales_order, {
        :quantity               => @repeat_quantity, 
        :is_pre_production      => true , 
        :is_production          => true, 
        :is_post_production     => false,
        :pre_production_price   => "50000", 
        :production_price       => "20000",
        :post_production_price  => "150000",
        :is_delivered           => true, 
        :delivery_address       => "Hahahahaa",
        :template_sales_item_id => @has_production_sales_item.template_sales_item_id 

      }) 
      
      
      @repeat_si.reload 
    end
    
    it 'should create repeat_si' do
      @repeat_si.should be_valid 
      @repeat_si.case.should == SALES_ITEM_CREATION_CASE[:repeat]
    end
    
    it 'should not create template' do
      @final_template_sales_item_count = TemplateSalesItem.count 
      diff = @final_template_sales_item_count-  @initial_template_sales_item_count
      diff.should == 0 
    end
  
    it 'should give the appropriate template' do
      @repeat_si.template_sales_item_id.should == @has_production_sales_item.template_sales_item_id 
    end
    
    it 'should not have sales item subcription (before confirmation)'  do
      @repeat_si.sales_item_subcription.should be_nil 
    end
    
    context 'confirming the second sales order' do
      before(:each) do
        @second_sales_order.confirm(@admin)
        @repeat_si.reload 
        @second_sales_order.reload 
      end
      
      it 'should confirm second sales order' do
        @second_sales_order.is_confirmed.should be_true 
        @repeat_si.is_confirmed.should be_true 
      end
      
      it 'should create sales item subcription for the repeat' do
        @repeat_si.sales_item_subcription.should be_valid 
      end
      
      it 'should confirm the second sales order' do
        @second_sales_order.is_confirmed.should be_true 
      end
      
      it 'should only have one sales_item_subcription' do
        template_sales_item = @has_production_sales_item.template_sales_item 
        SalesItemSubcription.where(
          :customer_id => @customer.id ,
          :template_sales_item_id => template_sales_item.id 
        ).count.should == 1  
        
        TemplateSalesItem.count.should == 1 
        
        template_sales_item.sales_items.count.should == 2 
      end
      
      it 'should have pending production, equal to the sum of 2 sales item quantities' do
        @sales_item_subcription_1 = @has_production_sales_item.sales_item_subcription
        @sales_item_subcription_2 = @repeat_si.sales_item_subcription 
        @sales_item_subcription_1.id.should == @sales_item_subcription_2.id 
        
        @sales_item_subcription_1.pending_production.should == @repeat_quantity + @has_production_quantity
      end
    end
    
    
    
    context "creating subcription history that spans 2 sales_item " do
      
    end
  end
    
  
end
