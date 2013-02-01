require 'spec_helper'

describe GuaranteeReturn do
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
  end
  
  it 'should confirm the delivery' do
    @delivery.is_confirmed.should be_true 
  end
  
  it 'should update the delivery_entry' do
    puts "\n\n\n\n"
    puts "In the update post delivery "
    puts "quantity_sent:#{@delivery_entry.quantity_sent } "
    puts "Delivery entry confirmation status: #{@delivery_entry.is_confirmed}"
    puts "Delivery confirmation status: #{@delivery.is_confirmed}"
    @delivery_entry.update_post_delivery(@admin, {
      :quantity_confirmed => @delivery_entry.quantity_sent , 
      :quantity_confirmed_weight => "#{@delivery_entry.quantity_sent * 10}",
      :quantity_returned => 0 ,
      :quantity_returned_weight => '0' ,
      :quantity_lost => 0
    })
    
    @delivery_entry.quantity_confirmed.should == @quantity_sent
  end
  
  

  it 'should have correct number of delivery entry, quantity_confirmed' do
    @delivery_entry.quantity_confirmed.should == @delivery_entry.quantity_sent 
  end
  
   
  it 'should have finalized delivery' do
    @delivery.errors.messages.each do |message|
      puts "The error: #{message}"
    end
    puts "Checking delivery entry"
    puts "The quantity_sent: #{@delivery_entry.quantity_sent }"
    @delivery.is_finalized.should be_true 
  end
  
  it 'should have the right number of fulfilled order ' do
    @complete_cycle_sales_item.fulfilled_order.should == @delivery_entry.quantity_sent
  end
  
  
  context "doing the guarantee return" do
    before(:each) do
      @guarantee_return = GuaranteeReturn.create_by_employee(@admin, {
        :customer_id => @customer.id ,
        :receival_date => Date.new( 2012,12,8)
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
    end
    
    it 'should create guarantee return' do
      @guarantee_return.should be_valid 
    end
    
    it 'should create guarantee return entry'  do
      @guarantee_return_entry.should be_valid 
    end
    
    context "confirming the guarantee return" do
      before(:each) do
        @complete_cycle_sales_item.reload 
        @initial_pending_production = @complete_cycle_sales_item.pending_production 
        @initial_pending_post_production = @complete_cycle_sales_item.pending_post_production 
        @initial_number_of_guarantee_return = @complete_cycle_sales_item.number_of_guarantee_return
        @initial_pending_guarantee_return_delivery = @complete_cycle_sales_item.pending_guarantee_return_delivery
        
        @guarantee_return.confirm(@admin)
        @complete_cycle_sales_item.reload 
      end
      
      # sales item statistic
      it 'should increase number_of_guarantee_return' do
        @final_number_of_guarantee_return = @complete_cycle_sales_item.number_of_guarantee_return
        diff = @final_number_of_guarantee_return - @initial_number_of_guarantee_return
        diff.should == @gre_post_production + @gre_production
      end
      
      it 'should increase pending_guarantee_return_delivery' do
        @final_pending_guarantee_return_delivery = @complete_cycle_sales_item.pending_guarantee_return_delivery
        diff = @final_pending_guarantee_return_delivery - @initial_pending_guarantee_return_delivery
        diff.should == @gre_post_production + @gre_production
      end
      
      it 'should increase the pending production'   do
        @final_pending_production = @complete_cycle_sales_item.pending_production 
        diff = @final_pending_production - @initial_pending_production
        diff.should == @gre_production
      end
      
      it 'should create production order' do
        ProductionOrder.where(
          :sales_item_id            => @complete_cycle_sales_item.id       ,
          :case                     => PRODUCTION_ORDER[:guarantee_return]     ,
          :quantity                 => @gre_production     ,
      
          :source_document_entry    => @guarantee_return_entry.class.to_s          ,
          :source_document_entry_id => @guarantee_return_entry.id                  ,
          :source_document          => @guarantee_return_entry.guarantee_return.class.to_s          ,
          :source_document_id       => @guarantee_return_entry.guarantee_return_id
        ).count.should == 1 
      end
      
      it 'should increase the pending post production' do
        @final_pending_post_production = @complete_cycle_sales_item.pending_post_production 
        diff = @final_pending_post_production - @initial_pending_post_production
        diff.should == @gre_post_production
      end
      
      it 'should create post production order' do 
        PostProductionOrder.where(
          :sales_item_id            => @complete_cycle_sales_item.id       ,
          :case                     => POST_PRODUCTION_ORDER[:guarantee_return]     ,
          :quantity                 => @gre_post_production     ,
      
          :source_document_entry    => @guarantee_return_entry.class.to_s          ,
          :source_document_entry_id => @guarantee_return_entry.id                  ,
          :source_document          => @guarantee_return_entry.guarantee_return.class.to_s          ,
          :source_document_id       => @guarantee_return_entry.guarantee_return_id
        ).count.should == 1
        
      end
      
      
    end # "confirming the guarantee return"
  end
   
end
