require 'spec_helper'

describe SubcriptionProductionHistory do
  before(:each) do
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
    @pre_production_price = '50000'
    @production_price = '20000'
    @post_production_price = '150000'
    
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
      :pre_production_price  => @pre_production_price , 
      :production_price      => @production_price,
      :post_production_price => @post_production_price
    })
    @sales_order.confirm(@admin)
    @sales_order.reload 
    @has_production_sales_item.reload 
    @sales_item_subcription = @has_production_sales_item.sales_item_subcription
  end
  
  it 'should be confirmed' do
    @sales_order.is_confirmed?.should be_true 
  end
  
  it 'should have pending production' do
    @has_production_sales_item.pending_production.should == @has_production_quantity
    @sales_item_subcription.pending_production.should == @has_production_quantity
  end
  
  it 'should create the subcription production history' do
    @ok_quantity              = 20
    @repairable_quantity      = 0 
    @broken_quantity          = 0 
    @ok_weight                = BigDecimal("#{@ok_quantity*10}")
    @repairable_weight        = BigDecimal("0")
    @broken_weight            = BigDecimal("0")
    @start_date               = Date.new(2013,1,12)
    @finish_date              = Date.new(2013,1,25)
    
    
    sph = SubcriptionProductionHistory.create_history( @admin, @sales_item_subcription , {
      :ok_quantity             => @ok_quantity           ,
      :repairable_quantity     => @repairable_quantity   ,
      :broken_quantity         => @broken_quantity       ,
      :ok_weight               => @ok_weight             ,
      :repairable_weight       => @repairable_weight     ,
      :broken_weight           => @broken_weight         ,
      :start_date              => @start_date            ,
      :finish_date             => @finish_date          
    } ) 
    
    sph.should be_valid 
  end
  
  it 'should not allow excess ok quantity' do
    @ok_quantity              = @has_production_quantity + 5 
    @repairable_quantity      = 0 
    @broken_quantity          = 0 
    @ok_weight                = BigDecimal("#{@ok_quantity*10}")
    @repairable_weight        = BigDecimal("0")
    @broken_weight            = BigDecimal("0")
    @start_date               = Date.new(2013,1,12)
    @finish_date              = Date.new(2013,1,25)
    
    
    sph = SubcriptionProductionHistory.create_history( @admin, @sales_item_subcription , {
      :ok_quantity             => @ok_quantity           ,
      :repairable_quantity     => @repairable_quantity   ,
      :broken_quantity         => @broken_quantity       ,
      :ok_weight               => @ok_weight             ,
      :repairable_weight       => @repairable_weight     ,
      :broken_weight           => @broken_weight         ,
      :start_date              => @start_date            ,
      :finish_date             => @finish_date          
    } ) 
    
    sph.should_not be_valid
  end
   
  context "after create" do
    
    before(:each) do
      @ok_quantity              = 20
      @repairable_quantity      = 0 
      @broken_quantity          = 0 
      @ok_weight                = BigDecimal("#{@ok_quantity*10}")
      @repairable_weight        = BigDecimal("0")
      @broken_weight            = BigDecimal("0")
      @start_date               = Date.new(2013,1,12)
      @finish_date              = Date.new(2013,1,25)


      @sph = SubcriptionProductionHistory.create_history( @admin, @sales_item_subcription , {
        :ok_quantity             => @ok_quantity           ,
        :repairable_quantity     => @repairable_quantity   ,
        :broken_quantity         => @broken_quantity       ,
        :ok_weight               => @ok_weight             ,
        :repairable_weight       => @repairable_weight     ,
        :broken_weight           => @broken_weight         ,
        :start_date              => @start_date            ,
        :finish_date             => @finish_date          
      } )
    end
    
    
    it 'should be confirmable' do
      puts "Gonna confirm testing\n"*10
      @sph.confirm(@admin)
      @sph.reload 
      @sph.is_confirmed.should be_true 
    end
    
    it 'should not allow 2 unconfirmed subcription production histories ' do
      @sph_2 = SubcriptionProductionHistory.create_history( @admin, @sales_item_subcription , {
        :ok_quantity             => @ok_quantity           ,
        :repairable_quantity     => @repairable_quantity   ,
        :broken_quantity         => @broken_quantity       ,
        :ok_weight               => @ok_weight             ,
        :repairable_weight       => @repairable_weight     ,
        :broken_weight           => @broken_weight         ,
        :start_date              => @start_date            ,
        :finish_date             => @finish_date          
      } )
      
      @sph_2.should be_nil 
    end
     
    
    context "post confirm" do
      before(:each) do 
        @sph.reload 
        @sales_item_subcription.reload
        @pre_confirm_pending_production = @sales_item_subcription.pending_production
        @pre_confirm_pending_post_production = @sales_item_subcription.pending_post_production
        @initial_production_history_count = @sph.production_histories 
        @sph.confirm(@admin)
        @sph.reload 
        @sales_item_subcription.reload
      end
      
      it 'should be confirmed' do
        puts "THe errors count:\n"
        puts "#{@sph.errors.size }"
        
        @sph.errors.messages.each do |msg|
          puts "#{msg}"
        end
        @sph.is_confirmed.should be_true 
      end
      
      it 'should create the actual production history, bound to the sales item' do 
        @final_production_history_count = @sph.production_histories
        diff = @final_production_history_count -  @initial_production_history_count
        diff.should_not == 0 
      end
       
      
      it 'should reduce the pending production' do
        @post_confirm_pending_production = @sales_item_subcription.pending_production
        diff = @pre_confirm_pending_production - @post_confirm_pending_production  
        diff.should == @ok_quantity
      end
      
      it 'should increase the pending post production for the post-production included' do
        @post_confirm_pending_post_production = @sales_item_subcription.pending_post_production 
        diff = @post_confirm_pending_post_production - @pre_confirm_pending_post_production 
        diff.should == (   @ok_quantity + @repairable_quantity) 
      end
    end # context "post confirm"
    
  end
  
end
