require 'spec_helper'

describe SubcriptionPostProductionHistory do
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
    
    
    # post confirm
    @sph.reload 
    @sales_item_subcription.reload
    @pre_confirm_pending_production = @sales_item_subcription.pending_production
    @pre_confirm_pending_post_production = @sales_item_subcription.pending_post_production
    @initial_production_history_count = @sph.production_histories 
    @sph.confirm(@admin)
    @sph.reload 
    @sales_item_subcription.reload
  end
  
  it 'should produce pending post production' do
    @sales_item_subcription.pending_post_production.should == @ok_quantity  + @repairable_quantity
  end
  
  it 'should create SubcriptionPostProductionHistory' do 
    @delta_post_production = 5  
    @ok_quantity              = @sales_item_subcription.pending_post_production - @delta_post_production
    @bad_source_quantity      = 0 
    @broken_quantity          = 0 
    @ok_weight                = BigDecimal("#{@ok_quantity*10}")
    @bad_source_weight        = BigDecimal("0")
    @broken_weight            = BigDecimal("0")
    @start_date               = Date.new(2013,1,12)
    @finish_date              = Date.new(2013,1,25)


    @spph = SubcriptionPostProductionHistory.create_history( @admin, @sales_item_subcription , {
      :ok_quantity             => @ok_quantity           ,
      :bad_source_quantity     => @bad_source_quantity   ,
      :broken_quantity         => @broken_quantity       ,
      :ok_weight               => @ok_weight             ,
      :bad_source_weight       => @bad_source_weight     ,
      :broken_weight           => @broken_weight         ,
      :start_date              => @start_date            ,
      :finish_date             => @finish_date          
    } )
    
    @spph.should be_valid 
  end
  
  it 'should not create SubcriptionPostProductionHistory if total ok exceed pending post production' do
    @delta_post_production = 5  
    @ok_quantity              = @sales_item_subcription.pending_post_production + 1 
    @bad_source_quantity      = 0 
    @broken_quantity          = 0 
    @ok_weight                = BigDecimal("#{@ok_quantity*10}")
    @bad_source_weight        = BigDecimal("0")
    @broken_weight            = BigDecimal("0")
    @start_date               = Date.new(2013,1,12)
    @finish_date              = Date.new(2013,1,25)


    @spph = SubcriptionPostProductionHistory.create_history( @admin, @sales_item_subcription , {
      :ok_quantity             => @ok_quantity           ,
      :bad_source_quantity     => @bad_source_quantity   ,
      :broken_quantity         => @broken_quantity       ,
      :ok_weight               => @ok_weight             ,
      :bad_source_weight       => @bad_source_weight     ,
      :broken_weight           => @broken_weight         ,
      :start_date              => @start_date            ,
      :finish_date             => @finish_date          
    } )
    
    @spph.should_not be_valid
  end
  
  it 'should not create SubcriptionPostProductionHistory if total sum of quantities exceed pending post production' do
    @delta_post_production = 5  
    @ok_quantity              = @sales_item_subcription.pending_post_production
    @bad_source_quantity      = 1 
    @broken_quantity          = 0 
    @ok_weight                = BigDecimal("#{@ok_quantity*10}")
    @bad_source_weight        = BigDecimal("0")
    @broken_weight            = BigDecimal("0")
    @start_date               = Date.new(2013,1,12)
    @finish_date              = Date.new(2013,1,25)


    @spph = SubcriptionPostProductionHistory.create_history( @admin, @sales_item_subcription , {
      :ok_quantity             => @ok_quantity           ,
      :bad_source_quantity     => @bad_source_quantity   ,
      :broken_quantity         => @broken_quantity       ,
      :ok_weight               => @ok_weight             ,
      :bad_source_weight       => @bad_source_weight     ,
      :broken_weight           => @broken_weight         ,
      :start_date              => @start_date            ,
      :finish_date             => @finish_date          
    } )
    
    @spph.should_not be_valid
  end
  
  context "post confirm spph" do
    before(:each) do
      @delta_post_production = 5  
      @ok_quantity              = @sales_item_subcription.pending_post_production - @delta_post_production
      @bad_source_quantity      = 0 
      @broken_quantity          = 0 
      @ok_weight                = BigDecimal("#{@ok_quantity*10}")
      @bad_source_weight        = BigDecimal("0")
      @broken_weight            = BigDecimal("0")
      @start_date               = Date.new(2013,1,12)
      @finish_date              = Date.new(2013,1,25)


      @spph = SubcriptionPostProductionHistory.create_history( @admin, @sales_item_subcription , {
        :ok_quantity             => @ok_quantity           ,
        :bad_source_quantity     => @bad_source_quantity   ,
        :broken_quantity         => @broken_quantity       ,
        :ok_weight               => @ok_weight             ,
        :bad_source_weight       => @bad_source_weight     ,
        :broken_weight           => @broken_weight         ,
        :start_date              => @start_date            ,
        :finish_date             => @finish_date          
      } )
      @sales_item_subcription.reload 
      @spph.should be_valid
      @initial_post_production_history_count = @spph.post_production_histories.count
      @spph.confirm(@admin)
      @spph.reload
      @sales_item_subcription.reload 
    end
    
    it 'should be confirmed' do
      @spph.is_confirmed.should be_true 
    end
    
    it 'should reduce the pending post production' do
      @sales_item_subcription.pending_post_production.should == @delta_post_production
    end
    
    it 'should produce one post production history' do
      @final_post_production_history_count = @spph.post_production_histories.count
      diff = @final_post_production_history_count - @initial_post_production_history_count
      diff.should == 1 
    end
    
  end  # context "post confirm spph"
  
  
  
  
  
end
