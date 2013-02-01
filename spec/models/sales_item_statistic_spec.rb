require 'spec_helper'

describe "sales item statistic spec" do
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
        :weight_per_piece   => '15' ,
        :name => "Sales Item",
        :is_pending_pricing    => false, 
        :is_pricing_by_weight  => false , 
        :pre_production_price  => "50000", 
        :production_price      => "20000",
        :post_production_price => "150000"
      }) 
  end
  
  context "confirming the sales order => generate production order" do
    before(:each) do
      @sales_order.confirm(@admin)
      @complete_cycle_sales_item.reload
    end
    
    it 'should create pending production' do
      @complete_cycle_sales_item.pending_production.should == @quantity_in_sales_item
    end
    
    context "creating production history" do
      before(:each) do
        # @quantity_in_sales_item = 50 
        @processed_quantity = 20
        @ok_quantity = 18 
        @broken_quantity = 1
        @repairable_quantity = 1 

        # @production_history = ProductionHistory.create_history( @admin, @complete_cycle_sales_item, {
        #   # :processed_quantity    => @processed_quantity, 
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
        @initial_sum_of_production_order= @complete_cycle_sales_item.production_orders.sum("quantity")
        @initial_sum_of_post_production_order = @complete_cycle_sales_item.post_production_orders.sum("quantity")
        @initial_number_of_productions =  @complete_cycle_sales_item.number_of_production
        @production_history.confirm(@admin)
        @complete_cycle_sales_item.reload
      end
      
      it 'should deduct the pending production' do 
        @final_pending_production =  @complete_cycle_sales_item.pending_production
        @final_sum_of_production_order = @complete_cycle_sales_item.production_orders.sum("quantity")
        
        diff = @initial_pending_production - @final_pending_production
        
        success_quantity = @ok_quantity
        fail_quantity = @broken_quantity
        repairable_quantity  = @repairable_quantity
        expected_diff =  success_quantity +  repairable_quantity
        expected_diff.should == diff  
      end
      
      it 'should add the number of productions' do
        @final_number_of_productions =  @complete_cycle_sales_item.number_of_production
        diff = @final_number_of_productions  - @initial_number_of_productions 
        
        diff.should == @ok_quantity + 
                       @repairable_quantity + 
                       @broken_quantity 
        
      end
      
      it 'should increase the pending postproductions' do
        @final_sum_of_post_production_order =  @complete_cycle_sales_item.post_production_orders.sum("quantity")
        diff = @final_sum_of_post_production_order  - @initial_sum_of_post_production_order
        
        diff.should == @ok_quantity + @repairable_quantity 
        
        diff.should == @complete_cycle_sales_item.pending_post_production 
      end
      
      context "creating post_production history" do
        before(:each) do
      
          @total_post_production_1 = @ok_quantity -2 

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

          @post_production_history.should be_valid 
          @complete_cycle_sales_item.reload
          
          # puts "BEFORE THE FUCKING CONFIRM\n"*10
          # puts "Pending post production: #{@complete_cycle_sales_item.pending_post_production}"
          @initial_pending_post_production = @complete_cycle_sales_item.pending_post_production 
          @initial_number_of_post_production =  @complete_cycle_sales_item.number_of_post_production 
          @initial_ready      = @complete_cycle_sales_item.ready
          @initial_production_order_quantity=  @complete_cycle_sales_item.production_orders.sum("quantity")
          @initial_pending_production  =  @complete_cycle_sales_item.pending_production 
          
          @post_production_history.confirm( @admin )
          @complete_cycle_sales_item.reload 
          @post_production_history.reload

        end
        
        it 'should be valid' do 
          @post_production_history.errors.messages.each do |key, values| 
            puts "The key is #{key.to_s}"
            values.each do |value|
              puts "\tthe value is #{value}"
            end
          end
          # @post_production_history.save!
          # @post_production_history.should be_valid #  << the call to valid over here is generating error
          # won't be valid anymore 
          @post_production_history.errors.size.should ==0 
         
        end
        
        it 'should confirm the post production history' do
        
          @post_production_history.is_confirmed.should be_true 
          # puts "Total count: #{PostProductionHistory.count}"
        end
        # 
        it 'should increase the production order' do 
          @final_production_order_quantity=  @complete_cycle_sales_item.production_orders.sum("quantity")
          diff = @final_production_order_quantity - @initial_production_order_quantity
          diff.should == @post_production_broken_1
        end
        
        it 'should update pending productions' do
          
          @final_pending_production  =  @complete_cycle_sales_item.pending_production 
          diff = @final_pending_production - @initial_pending_production 
          diff.should ==  @post_production_broken_1 # pending production is the same
        end
         
        it 'should update pending post_productions' do 
          
          # puts "ok quantity: #{@post_production_ok_1}"
          # puts "initial pending post production: #{@initial_pending_post_production}\n"*10
          @final_pending_post_production = @complete_cycle_sales_item.pending_post_production 
          diff = @initial_pending_post_production  - @final_pending_post_production
          
          diff.should == @post_production_ok_1 + @post_production_broken_1
        end
        
        it 'should update the ready' do
          @final_ready      = @complete_cycle_sales_item.ready
          diff = @final_ready - @initial_ready
          diff.should == @post_production_ok_1
        end
        
        context "creating delivery" do
          before(:each) do
            @delivery   = Delivery.create_by_employee( @admin , {
              :customer_id    => @customer.id,          
              :delivery_address   => "some address",    
              :delivery_date     => Date.new(2012, 12, 15)
            })
        
        
            #create delivery entry
            @pending_delivery = @complete_cycle_sales_item.ready 
        
            @quantity_sent = 1 
            if @pending_delivery > 1 
              @quantity_sent = @pending_delivery - 1 
            end
            
            @delivery_entry = DeliveryEntry.create_delivery_entry( @admin, @delivery,   {
                :quantity_sent => @quantity_sent, 
                :quantity_sent_weight => "#{@quantity_sent * 10}" ,
                :sales_item_id => @complete_cycle_sales_item.id 
              })
        
            #confirm delivery
            @complete_cycle_sales_item.reload 
            @initial_ready = @complete_cycle_sales_item.ready 
            @initial_on_delivery = @complete_cycle_sales_item.on_delivery 
        
            @delivery.confirm( @admin ) 
            @complete_cycle_sales_item.reload 
            @delivery_entry.reload
          end
          
          it 'should update the ready quantity' do
            @final_ready = @complete_cycle_sales_item.ready
            diff = @initial_ready - @final_ready
            diff.should == @quantity_sent
          end
          
          it 'should update the on delivery' do
            @final_on_delivery = @complete_cycle_sales_item.on_delivery
            diff = @final_on_delivery  - @initial_on_delivery
            diff.should == @quantity_sent
            
            # puts "quantity_sent: #{@quantity_sent}"  #14
          end
          
          context "finalize delivery" do
            before(:each) do
              @quantity_returned = 2
              @quantity_lost = 3 
              @quantity_confirmed =   @delivery_entry.quantity_sent - @quantity_returned  - @quantity_lost 
        
        
              @delivery_entry.update_post_delivery(@admin, {
                :quantity_confirmed => @quantity_confirmed , 
                :quantity_confirmed_weight =>  "#{@quantity_confirmed*10 }", 
                :quantity_returned => @quantity_returned ,
                :quantity_returned_weight => "#{@quantity_returned*20}" ,
                :quantity_lost => @quantity_lost  
              })
              
              @complete_cycle_sales_item.reload 
              @initial_on_delivery_item = @complete_cycle_sales_item.on_delivery 
              @initial_fulfilled = @complete_cycle_sales_item.fulfilled_order
        
              @initial_pending_production  =  @complete_cycle_sales_item.pending_production 
              @initial_production_order =  @complete_cycle_sales_item.production_orders.sum("quantity") 
              
              @initial_delivery_lost = @complete_cycle_sales_item.number_of_delivery_lost
              @delivery.reload 
              @delivery.finalize(@admin)
              @delivery.reload
        
              # @delivery.finalize(@admin)  
              @complete_cycle_sales_item.reload
              @delivery_lost = @delivery.delivery_lost
              @delivery_entry.reload 
              @sales_return = @delivery.sales_return 
            end
            
            it 'should have sales return' do
              @sales_return.should be_valid
            end
            
            it 'should have delivery_lost' do
              @delivery_lost.should be_valid 
            end
            
            it 'should deduct the on delivery item' do
              @final_on_delivery_item = @complete_cycle_sales_item.on_delivery 
              diff = @initial_on_delivery_item - @final_on_delivery_item 
              
              total_post_delivery_recap = @delivery_entry.quantity_confirmed +  
                                          @delivery_entry.quantity_returned + 
                                          @delivery_entry.quantity_lost  
              
              
              
              diff.should == total_post_delivery_recap 
            end
            
            it 'should add the fulfilled order' do 
              @final_fulfilled = @complete_cycle_sales_item.fulfilled_order
              diff = @final_fulfilled - @initial_fulfilled
              
              diff.should == @delivery_entry.quantity_confirmed
            end
            
            it 'should add pending production according to the delivery lost quantity' do
              @final_pending_production  =  @complete_cycle_sales_item.pending_production 
              diff = @final_pending_production  - @initial_pending_production
              # diff.should == @quantity_lost
              
              # puts "initial pending production: #{@initial_pending_production}"
              # puts "final pending production: #{@final_pending_production}"
              diff.should == @quantity_lost 
            end
            
            it 'should add the production order' do
              @final_production_order =  @complete_cycle_sales_item.production_orders.sum("quantity")
              diff = @final_production_order - @initial_production_order
              
              diff.should == @quantity_lost
              # puts "The diff: #{diff}"
            end
            
            it 'should add the number of delivery lost ' do 
              @final_delivery_lost = @complete_cycle_sales_item.number_of_delivery_lost
              diff = @final_delivery_lost - @initial_delivery_lost 
              diff.should == @quantity_lost
              
              # puts "final delivery lost :#{@final_delivery_lost}"
            end
            
            it 'should have only one sales return entry' do
               @sales_return.sales_return_entries.count.should == 1 
            end
            
            context "finalize sales return" do
              before(:each) do
                @sales_return_entry = @sales_return.sales_return_entries.first 
                @quantity_return_for_production = 1 
                @quantity_return_for_post_production = @quantity_returned - @quantity_return_for_production
                @initial_production_order = @complete_cycle_sales_item.production_orders.sum("quantity")
                @initial_pending_production = @complete_cycle_sales_item.pending_production
                
                @initial_post_production_order = @complete_cycle_sales_item.post_production_orders.sum("quantity")
                @initial_pending_post_production = @complete_cycle_sales_item.pending_post_production 
                
                @sales_return_entry.update_return_handling( {
                  :quantity_for_production => @quantity_return_for_production, 
                  :weight_for_production => "#{@quantity_return_for_production*8}",

                  :quantity_for_post_production => @quantity_return_for_post_production,
                  :weight_for_post_production => "#{@quantity_return_for_post_production*7}"
                })
                @sales_return.confirm(@admin)
                @complete_cycle_sales_item.reload 
              end
              
              it 'should confirm the sales return' do
                @sales_return.is_confirmed.should be_true 
              end
              
              it 'should confirm all sales return entries ' do
                @sales_return.sales_return_entries.each do |sre|
                  sre.is_confirmed.should be_true 
                end
              end
              
              it 'should produce confirmed sales return entries' do
                puts "TOTAL SALES RETURN ENTRIES: "
                @complete_cycle_sales_item.sales_return_entries.each do |sre|
                  sre.is_confirmed.should be_true 
                  sre.should be_valid 
                end
                
                confirmed_sre = @complete_cycle_sales_item.sales_return_entries.where(:is_confirmed => true).count
                total_sre = @complete_cycle_sales_item.sales_return_entries.count 
                puts "TOTAL SRE: #{total_sre}"
                puts "$$$$$$$$$$$ the confirmed sre : #{confirmed_sre}\n"*10
                # @complete_cycle_sales_item.sales_return_entries.where(:is_confirmed => true).count.should == 1 
              end
              
              it 'should add quota for un adjusted post production failure replacement' do
                
                puts "Total confirmed_sales_return_entries: #{@complete_cycle_sales_item.sales_return_entries.where(:is_confirmed => true).count}"
                @complete_cycle_sales_item.quota_for_post_production_failure_replacement.should == @quantity_return_for_post_production
              end
              
              
              
              it 'should increase pending_production' do
                @final_pending_production = @complete_cycle_sales_item.pending_production
                diff = @final_pending_production- @initial_pending_production
                diff.should == @quantity_return_for_production
              end
              
              it 'should increase production order' do
                @final_production_order = @complete_cycle_sales_item.production_orders.sum("quantity")
                diff = @final_production_order - @initial_production_order
                diff.should == @quantity_return_for_production
              end
              
              it 'should increase pending_post_production' do
                @final_pending_post_production = @complete_cycle_sales_item.pending_post_production 
                diff = @final_pending_post_production -  @initial_pending_post_production
                
                diff.should == @quantity_return_for_post_production
              end
              
              it 'should increase post_production_order' do
                @final_post_production_order = @complete_cycle_sales_item.post_production_orders.sum("quantity")
                diff = @final_post_production_order - @initial_post_production_order
                
                diff.should == @quantity_return_for_post_production
              end
              # 
              
              
              context "creating post production history after sales return with quantity for post production" do
                before(:each) do
                  @quantity_for_post_production = @complete_cycle_sales_item.pending_post_production
                  @quantity_broken = 2 
                  @quantity_ok  = @quantity_for_post_production - @quantity_broken
                  # @post_production_history = PostProductionHistory.create_history( @admin, @complete_cycle_sales_item, {
                  #   :ok_quantity           => @quantity_ok, 
                  #   :broken_quantity       => @quantity_broken, 
                  #   :bad_source_quantity => 0, 
                  #               
                  #   :ok_weight             =>  "#{@quantity_ok*15}" ,  # in kg.. .00 
                  #   :broken_weight         =>  "#{@quantity_broken*10}" ,
                  #   :bad_source_weight => '0',
                  #               
                  #   # :person_in_charge      => nil ,# list of employee id 
                  #   :start_date            => Date.new( 2012, 10,10 ) ,
                  #   :finish_date           => Date.new( 2013, 1, 15) 
                  # })
                  
                  @sales_item_subcription.reload 
                  @post_production_history = SubcriptionPostProductionHistory.create_history( @admin, @sales_item_subcription , {
                    :ok_quantity             => @quantity_ok           ,
                    :bad_source_quantity     => 0   ,
                    :broken_quantity         => @quantity_broken       ,
                    :ok_weight               => "#{@quantity_ok*15}"              ,
                    :bad_source_weight       =>  '0'  ,
                    :broken_weight           => "#{@quantity_broken*10}"       ,
                    :start_date              => Date.new( 2012, 10,10 )            ,
                    :finish_date             => Date.new( 2013, 1, 15)        
                  } )
                  
                  @initial_pending_production = @complete_cycle_sales_item.pending_production 
                  @initial_production_orders = @complete_cycle_sales_item.production_orders.sum("quantity")
                  @post_production_history.confirm(@admin)
                  @complete_cycle_sales_item.reload
                end
                
                it 'should add pending production by the amount of sales_return going to post production' do
                  @final_pending_production = @complete_cycle_sales_item.pending_production 
                  diff = @final_pending_production  - @initial_pending_production
                  diff.should == @quantity_broken
                end
              
                it 'should add production orders by the amount of all failed post production' do
                  @final_production_orders = @complete_cycle_sales_item.production_orders.sum("quantity")
                  diff = @final_production_orders - @initial_production_orders
                  diff.should == @quantity_broken
                end
                
                
              end # "creating post production history after sales return with quantity for post production" 
              
              
              
            end#"finalize sales return"
            
          end #"finalize delivery"
          
        end  # "creating delivery"
        
      end# "creating post_production history"
    end# "creating production history"
    
  end # context: "confirming the sales order => generate production order"

  
   
end
