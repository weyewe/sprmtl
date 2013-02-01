require 'spec_helper'

describe "delivery return delivery spec" do
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
        :weight_per_piece   => '15',
        :name => "Sales Item" ,
        :is_pending_pricing    => false, 
        :is_pricing_by_weight  => false , 
        :pre_production_price  => "50000", 
        :production_price      => "20000",
        :post_production_price => "150000"
      })
    
    
   

    @sales_order.confirm(@admin)
    @complete_cycle_sales_item.reload
    
    @processed_quantity = 20
    @ok_quantity = 18 
    @broken_quantity = 1
    @repairable_quantity = 1 
    
    # @production_history = ProductionHistory.create_history( @admin, @complete_cycle_sales_item, {
    #   :processed_quantity    => @processed_quantity, 
    #   :ok_quantity           => @ok_quantity, 
    #   :repairable_quantity   => @repairable_quantity, 
    #   :broken_quantity       => @broken_quantity, 
    # 
    #   :ok_weight             =>  "#{8*15}" ,  # in kg.. .00 
    #   :repairable_weight     => '13',
    #   :broken_weight         =>  "#{2*10}" ,
    # 
    #   # :person_in_charge      => nil ,# list of employee id 
    #   :start_date            => Date.new( 2012, 10,10 ) ,
    #   :finish_date           => Date.new( 2013, 1, 15) 
    # })
    
    @sales_item_subcription = @complete_cycle_sales_item.sales_item_subcription
    @production_history = SubcriptionProductionHistory.create_history( @admin, @sales_item_subcription , {
      :ok_quantity             => @ok_quantity           ,
      :repairable_quantity     => @repairable_quantity   ,
      :broken_quantity         => @broken_quantity       ,
      :ok_weight               => "#{8*15}"          ,
      :repairable_weight       => '13'     ,
      :broken_weight           => "#{2*10}"         ,
      :start_date              => Date.new( 2012, 10,10 )          ,
      :finish_date             => Date.new( 2013, 1, 15)      
    } )
    
    @initial_pending_production = @complete_cycle_sales_item.pending_production
    @initial_pending_post_production = @complete_cycle_sales_item.pending_post_production 
    
    @production_history.confirm(@admin)
    @complete_cycle_sales_item.reload
    @pending_post_production = @complete_cycle_sales_item.pending_post_production
    
    @total_post_production_1 = 15
    
    @post_production_broken_1 = 1 
    @post_production_ok_1 = @total_post_production_1 - @post_production_broken_1
    # @post_production_history = PostProductionHistory.create_history( @admin, @complete_cycle_sales_item, {
    #   :ok_quantity           => @post_production_ok_1, 
    #   :broken_quantity       => @post_production_broken_1, 
    #   :bad_source_quantity => 0, 
    # 
    #   :ok_weight             =>  "#{@post_production_ok_1*15}" ,  # in kg.. .00 
    #   :broken_weight         =>  "#{@post_production_broken_1*10}" ,
    #   :bad_source_weight => '0',
    # 
    #   # :person_in_charge      => nil ,# list of employee id 
    #   :start_date            => Date.new( 2012, 10,10 ) ,
    #   :finish_date           => Date.new( 2013, 1, 15) 
    # })
    
    @sales_item_subcription.reload 
    @post_production_history = SubcriptionPostProductionHistory.create_history( @admin, @sales_item_subcription , {
      :ok_quantity             => @post_production_ok_1           ,
      :bad_source_quantity     => 0   ,
      :broken_quantity         => @post_production_broken_1       ,
      :ok_weight               => "#{@post_production_ok_1*15}"              ,
      :bad_source_weight       =>  '0'  ,
      :broken_weight           => "#{@post_production_broken_1*10}"       ,
      :start_date              => Date.new( 2012, 10,10 )            ,
      :finish_date             => Date.new( 2013, 1, 15)        
    } )
    
    @complete_cycle_sales_item.reload 
    
    @initial_pending_post_production = @complete_cycle_sales_item.pending_post_production 
    @initial_ready      = @complete_cycle_sales_item.ready
    @initial_pending_production  =  @complete_cycle_sales_item.pending_production 
    
    @post_production_history.confirm( @admin ) 

    @complete_cycle_sales_item.reload
    
  
  ###### 
  ###### 
  ######  
  # => By now, post production ok == 15 
  ######
  ###### 
  ###### 
    
    @delivery   = Delivery.create_by_employee( @admin , {
      :customer_id    => @customer.id,          
      :delivery_address   => "some address",    
      :delivery_date     => Date.new(2012, 12, 15)   
    })
    
    @quantity_sent = 10 
    
    @delivery_entry = DeliveryEntry.create_delivery_entry( @admin, @delivery,  {
        :quantity_sent => @quantity_sent, 
        :quantity_sent_weight => "#{@quantity_sent * 10}" ,
        :sales_item_id => @complete_cycle_sales_item.id
      })
    
    #
    # => Confirm Delivery 
    #
    @delivery.confirm( @admin )
    @delivery.reload 
    @delivery_entry.reload  
    # 
    @delivery_entry.update_post_delivery(@admin, {
      :quantity_confirmed => @delivery_entry.quantity_sent , 
      :quantity_confirmed_weight => "#{@delivery_entry.quantity_sent * 10}",
      :quantity_returned => 0 ,
      :quantity_returned_weight => '0' ,
      :quantity_lost => 0
    })
    
    @delivery.reload 
    @delivery_entry.reload 
    
    @delivery.finalize(@admin)
    
    @delivery_entry.reload
    @delivery.reload 
    @complete_cycle_sales_item.reload 
    
    @guarantee_return = GuaranteeReturn.create_by_employee(@admin, {
      :customer_id => @customer.id 
    })
    
    # quantity_sent == 10 
    @gre_post_production = 3
    @gre_production = 2 
   
    
    @guarantee_return_entry = GuaranteeReturnEntry.create_guarantee_return_entry( @admin, @guarantee_return ,  {
      :sales_item_id                  => @complete_cycle_sales_item.id ,
      :quantity_for_post_production   => @gre_post_production,
      :quantity_for_production        => @gre_production,
      :weight_for_post_production     => "#{@gre_post_production*10}", 
      :weight_for_production          => "#{@gre_production*10}"
    } )    
    
    @complete_cycle_sales_item.reload 
    @initial_pending_production = @complete_cycle_sales_item.pending_production 
    @initial_pending_post_production = @complete_cycle_sales_item.pending_post_production 
    
    @guarantee_return.confirm(@admin)
    @complete_cycle_sales_item.reload
  end
   
  context "creating the delivery only for this guarantee return delivery: 1 delivery entry" do
    before(:each) do
      @delivery   = Delivery.create_by_employee( @admin , {
        :customer_id    => @customer.id,          
        :delivery_address   => "some address",    
        :delivery_date     => Date.new(2012, 12, 15)
      })
      
      # quantity_sent = 10
      #gre_production = 2
      #gre_post_production = 3
      # remaining ready = 4
      
      @gr_delivery_quantity  = 2 
      
      
      @delivery_entry = DeliveryEntry.create_delivery_entry( @admin, @delivery,  {
          :quantity_sent => @gr_delivery_quantity, 
          :quantity_sent_weight => "#{@gr_delivery_quantity * 10}" ,
          :sales_item_id => @complete_cycle_sales_item.id,
          :entry_case => DELIVERY_ENTRY_CASE[:guarantee_return]
        })
    end
    
    it 'should not create sales invoice' do
      @delivery.invoice.should be_nil 
    end
    
    it 'should create delivery and delivery_entry' do
      puts "Total number of errors in delivery: #{@delivery.errors.size}"
      puts "Total number of errors in delivery_entry: #{@delivery_entry.errors.size}"
      
      @delivery_entry.errors.messages.each do |message|
        puts "The message : #{message}"
      end
      
      @delivery.should be_valid
      @delivery_entry.should be_valid
    end
    
    it 'should create entry case as guarantee return' do
      @delivery_entry.entry_case.should ==  DELIVERY_ENTRY_CASE[:guarantee_return]
    end
    
    context "confirming delivery" do
      before(:each) do 
        @delivery.confirm(@admin)
      end
      
      it 'should confirm delivery' do
        @delivery.is_confirmed.should be_true 
      end
      
      
      
      context "finalizing delivery " do
        before(:each) do
          @delivery.reload 
          @delivery_entry.reload 
          @complete_cycle_sales_item.reload 
          
          @initial_number_of_guarantee_return = @complete_cycle_sales_item.number_of_guarantee_return
          @initial_pending_guarantee_return_delivery = @complete_cycle_sales_item.pending_guarantee_return_delivery
          @initial_fulfilled_order = @complete_cycle_sales_item.fulfilled_order
          
          @delivery_entry.update_post_delivery(@admin, {
            :quantity_confirmed => @delivery_entry.quantity_sent , 
            :quantity_confirmed_weight => "#{@delivery_entry.quantity_sent * 10}",
            :quantity_returned => 0 ,
            :quantity_returned_weight => '0' ,
            :quantity_lost => 0
          })
           
          @delivery.finalize(@admin)
          @delivery.reload 
          @complete_cycle_sales_item.reload 
        end
        
        it 'should finalize' do
          @delivery.is_finalized.should be_true 
        end
        
        it 'should deduct the pending_guarantee_return_delivery' do
          @final_pending_guarantee_return_delivery = @complete_cycle_sales_item.pending_guarantee_return_delivery
          diff =  @initial_pending_guarantee_return_delivery - @final_pending_guarantee_return_delivery 
          diff.should == @delivery_entry.quantity_sent 
        end
        
        it 'should do nothing to the number of guarantee_return' do
           @final_number_of_guarantee_return = @complete_cycle_sales_item.number_of_guarantee_return
           diff = @final_number_of_guarantee_return - @initial_number_of_guarantee_return
           diff.should == 0 
        end
        
        it 'should do nothing to the fulfilled_order' do
          @final_fulfilled_order = @complete_cycle_sales_item.fulfilled_order
          diff=  @initial_fulfilled_order  - @final_fulfilled_order
          diff.should == 0 
        end
        
      end # "finalizing delivery"
      
      
    end 
  end # "creating the delivery only for this guarantee return delivery" 
  
  
  
  ##################################################################
  ###############################################
  ##################### 2 delivery entries 
  ##############################################
  #################################################################
  context "creating the delivery only for this guarantee return delivery: 2 delivery entry" do
    before(:each) do
      @delivery   = Delivery.create_by_employee( @admin , {
        :customer_id    => @customer.id,          
        :delivery_address   => "some address",    
        :delivery_date     => Date.new(2012, 12, 15)
      })
      
      # quantity_sent = 10
      #gre_production = 2
      #gre_post_production = 3
      # remaining ready = 4
      
      @gr_delivery_quantity  = 2 
      @normal_delivery_quantity = 2 
      
      
      @delivery_entry = DeliveryEntry.create_delivery_entry( @admin, @delivery,  {
          :quantity_sent => @gr_delivery_quantity, 
          :quantity_sent_weight => "#{@gr_delivery_quantity * 10}" ,
          :sales_item_id => @complete_cycle_sales_item.id,
          :entry_case => DELIVERY_ENTRY_CASE[:guarantee_return]
        })

      @normal_delivery_entry = DeliveryEntry.create_delivery_entry( @admin, @delivery,  {
        :quantity_sent => @normal_delivery_quantity, 
        :quantity_sent_weight => "#{@normal_delivery_quantity * 10}" ,
        :sales_item_id => @complete_cycle_sales_item.id 
        })
    end
    
    it 'should create delivery and delivery_entry' do 
      
      @delivery.should be_valid
      @delivery_entry.should be_valid
      @normal_delivery_entry.should be_valid
    end
    
    it 'should create entry case as guarantee return' do
      @delivery_entry.entry_case.should ==  DELIVERY_ENTRY_CASE[:guarantee_return]
      @normal_delivery_entry.entry_case.should == DELIVERY_ENTRY_CASE[:ready_post_production]
    end
    
    context "confirming delivery" do
      before(:each) do 
        @delivery.confirm(@admin)
      end
      
      it 'should confirm delivery' do
        @delivery.is_confirmed.should be_true 
      end
      
      
        
      context "finalizing delivery " do
        before(:each) do
          @delivery.reload 
          @delivery_entry.reload 
          @normal_delivery_entry.reload 
          @complete_cycle_sales_item.reload 
          
          @initial_number_of_guarantee_return = @complete_cycle_sales_item.number_of_guarantee_return
          @initial_pending_guarantee_return_delivery = @complete_cycle_sales_item.pending_guarantee_return_delivery
          @initial_fulfilled_order = @complete_cycle_sales_item.fulfilled_order
          
          @delivery_entry.update_post_delivery(@admin, {
            :quantity_confirmed => @delivery_entry.quantity_sent , 
            :quantity_confirmed_weight => "#{@delivery_entry.quantity_sent * 10}",
            :quantity_returned => 0 ,
            :quantity_returned_weight => '0' ,
            :quantity_lost => 0
          })
          
          @normal_delivery_entry.update_post_delivery(@admin, {
            :quantity_confirmed => @normal_delivery_entry.quantity_sent , 
            :quantity_confirmed_weight => "#{@normal_delivery_entry.quantity_sent * 10}",
            :quantity_returned => 0 ,
            :quantity_returned_weight => '0' ,
            :quantity_lost => 0
          })
           
          @delivery.finalize(@admin)
          @delivery.reload 
          @complete_cycle_sales_item.reload 
        end
        
        it 'should finalize' do
          @delivery.is_finalized.should be_true 
        end
        
        it 'should deduct the pending_guarantee_return_delivery' do
          @final_pending_guarantee_return_delivery = @complete_cycle_sales_item.pending_guarantee_return_delivery
          diff =  @initial_pending_guarantee_return_delivery - @final_pending_guarantee_return_delivery 
          diff.should == @delivery_entry.quantity_sent  
        end
        
        it 'should do nothing to the number of guarantee_return' do
           @final_number_of_guarantee_return = @complete_cycle_sales_item.number_of_guarantee_return
           diff = @final_number_of_guarantee_return - @initial_number_of_guarantee_return
           diff.should == 0 
        end
        
        it 'should add fulfilled order based on the normal delivery' do
          @final_fulfilled_order = @complete_cycle_sales_item.fulfilled_order
          diff=  @final_fulfilled_order - @initial_fulfilled_order  
          diff.should ==  @normal_delivery_entry.quantity_sent 
        end
        
      end # "finalizing delivery"
      
      
    end  # "confirming delivery"
  end # "creating the delivery only for this guarantee return delivery"
  
  
   
   
end
