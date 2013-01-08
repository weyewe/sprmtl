require 'spec_helper'

describe PostProductionHistory do
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
                                            
    @joko = FactoryGirl.create(:employee,  :name => "Joko" )
    @joni = FactoryGirl.create(:employee,  :name => "Joni" )
                                            
    @sales_order   = SalesOrder.create_by_employee( @admin , {
      :customer_id    => @customer.id,          
      :payment_term   => PAYMENT_TERM[:cash],    
      :order_date     => Date.new(2012, 12, 15)   
    })
   
    
    @quantity_in_sales_item = 50 
    @complete_cycle_sales_item = SalesItem.create_sales_item( @admin, @sales_order,  {
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
        :price_per_piece => "90000", 
        :weight_per_piece   => '15' ,
        :name => "Sales Item"
      })
    
    
   

    @sales_order.confirm(@admin)
    @complete_cycle_sales_item.reload
    
    @processed_quantity = 10
    @ok_quantity = 8 
    @broken_quantity = 1
    @repairable_quantity = 1 
    
    @production_history = ProductionHistory.create_history( @admin, @complete_cycle_sales_item, {
      :processed_quantity    => @processed_quantity, 
      :ok_quantity           => @ok_quantity, 
      :repairable_quantity   => @repairable_quantity, 
      :broken_quantity       => @broken_quantity, 

      :ok_weight             =>  "#{8*15}" ,  # in kg.. .00 
      :repairable_weight     => '13',
      :broken_weight         =>  "#{2*10}" ,

      # :person_in_charge      => nil ,# list of employee id 
      :start_date            => Date.new( 2012, 10,10 ) ,
      :finish_date           => Date.new( 2013, 1, 15) 
    })
    
    @initial_pending_production = @complete_cycle_sales_item.pending_production
    @initial_pending_post_production = @complete_cycle_sales_item.pending_post_production 
    
    @production_history.confirm(@admin)
    @complete_cycle_sales_item.reload
    @pending_post_production = @complete_cycle_sales_item.pending_post_production 
    
  end
   
  it 'should produce post production amount: ok_quantity + broken quantity' do
    @pending_post_production = @complete_cycle_sales_item.pending_post_production 
    @pending_post_production.should == @ok_quantity + @broken_quantity
  end
  
  it 'should create post production history if the processed quantity < pending post production' do
    broken_quantity = 1 
    ok_quantity = @pending_post_production- broken_quantity
    post_production_history = PostProductionHistory.create_history( @admin, @complete_cycle_sales_item, {
      :ok_quantity           => ok_quantity, 
      :broken_quantity       => broken_quantity, 

      :ok_weight             =>  "#{8*15}" ,  # in kg.. .00 
      :broken_weight         =>  "#{2*10}" ,

      # :person_in_charge      => nil ,# list of employee id 
      :start_date            => Date.new( 2012, 10,10 ) ,
      :finish_date           => Date.new( 2013, 1, 15) 
    })
    
    post_production_history.should be_valid 
  end
  
  
  it 'should not allow post production history creation if there is unconfirmed post production history' do
    extra_quantity = 1 
    broken_quantity = 1 
    ok_quantity = @pending_post_production- broken_quantity + extra_quantity 
    post_production_history = PostProductionHistory.create_history( @admin, @complete_cycle_sales_item, {
      :ok_quantity           => ok_quantity, 
      :broken_quantity       => broken_quantity, 

      :ok_weight             =>  "#{8*15}" ,  # in kg.. .00 
      :broken_weight         =>  "#{2*10}" ,

      # :person_in_charge      => nil ,# list of employee id 
      :start_date            => Date.new( 2012, 10,10 ) ,
      :finish_date           => Date.new( 2013, 1, 15) 
    })
    
    post_production_history.should_not be_valid 
    
  end
  
  
  
  it 'should not create post production history if the processed quantity > pending post production' do
    broken_quantity_1 = 1 
    ok_quantity_1 =  1 
    
    
    post_production_history_1 = PostProductionHistory.create_history( @admin, @complete_cycle_sales_item, {
      :ok_quantity           => ok_quantity_1, 
      :broken_quantity       => broken_quantity_1, 

      :ok_weight             =>  "#{8*15}" ,  # in kg.. .00 
      :broken_weight         =>  "#{2*10}" ,

      # :person_in_charge      => nil ,# list of employee id 
      :start_date            => Date.new( 2012, 10,10 ) ,
      :finish_date           => Date.new( 2013, 1, 15) 
    })
    
    broken_quantity_2 = 1
    ok_quantity_2 =  @pending_post_production - broken_quantity_1 - ok_quantity_1 - 
                        broken_quantity_2
    
    post_production_history_2 = PostProductionHistory.create_history( @admin, @complete_cycle_sales_item, {
      :ok_quantity           => ok_quantity_2, 
      :broken_quantity       => broken_quantity_2, 

      :ok_weight             =>  "#{8*15}" ,  # in kg.. .00 
      :broken_weight         =>  "#{2*10}" ,

      # :person_in_charge      => nil ,# list of employee id 
      :start_date            => Date.new( 2012, 10,10 ) ,
      :finish_date           => Date.new( 2013, 1, 15) 
    })
    
    post_production_history_2.should be_nil 
    
  end
  
  
  context "confirming post confirm post production spec" do
    before(:each) do
      @total_post_production_1 = 4 
      
      @post_production_broken_1 = 1 
      @post_production_ok_1 = @total_post_production_1 - @post_production_broken_1
      @post_production_history = PostProductionHistory.create_history( @admin, @complete_cycle_sales_item, {
        :ok_quantity           => @post_production_ok_1, 
        :broken_quantity       => @post_production_broken_1, 

        :ok_weight             =>  "#{@post_production_ok_1*15}" ,  # in kg.. .00 
        :broken_weight         =>  "#{@post_production_broken_1*10}" ,

        # :person_in_charge      => nil ,# list of employee id 
        :start_date            => Date.new( 2012, 10,10 ) ,
        :finish_date           => Date.new( 2013, 1, 15) 
      })
      
      @complete_cycle_sales_item.reload 
      
      @initial_pending_post_production = @complete_cycle_sales_item.pending_post_production 
      @initial_ready      = @complete_cycle_sales_item.ready
      @initial_pending_production  =  @complete_cycle_sales_item.pending_production 
      
      @post_production_history.confirm( @admin ) 

      @complete_cycle_sales_item.reload 
    end
    
    
    it 'should deduct the pending post production by the number of ok_quantity + broken quantity' do
      @final_pending_post_production = @complete_cycle_sales_item.pending_post_production 
      
      delta = @initial_pending_post_production - @final_pending_post_production
      
      delta.should == @post_production_ok_1 + @post_production_broken_1 
    end
    
    it 'should add the ready item by ok quantity' do
      @final_ready = @complete_cycle_sales_item.ready 
      
      delta =  @final_ready - @initial_ready 
      
      delta.should == @post_production_ok_1
    end
    
    it 'should NOT add the pending_production   by broken quantity' do
      @final_pending_production  =  @complete_cycle_sales_item.pending_production
      
      delta = @final_pending_production - @initial_pending_production
      
      delta.should ==  @post_production_broken_1
    end
    
    it 'should create ProductionOrder for the PRODUCTION_ORDER[:post_production_failure]' do
      @complete_cycle_sales_item.post_production_failure_production_orders.where(:source_document_entry_id => @post_production_history.id ).count == 1
      post_production_failure_production_order = @complete_cycle_sales_item.post_production_failure_production_orders.where(:source_document_entry_id => @post_production_history.id ).first 
      
      
      post_production_failure_production_order.quantity.should == @post_production_broken_1
    end
  end #"confirming post confirm post production spec"
  
  
   
  
  
  
end
