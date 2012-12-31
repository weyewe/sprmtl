require 'spec_helper'

describe Delivery do
  before(:each) do
    @admin = FactoryGirl.create(:user, :email => "admin@gmail.com", :password => "willy1234", :password_confirmation => "willy1234")
  
    
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
        :material_id => MATERIAL[:steel][:value], 
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
        :weight_per_piece   => '15' 
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
  
  it 'should not allow sales order creation if there is no employee' do 
    delivery   = Delivery.create_by_employee( nil , {
      :customer_id    => @customer.id,          
      :delivery_address   => "some address",    
      :delivery_date     => Date.new(2012, 12, 15) 
    })
    
    delivery.should be_nil 
  end
  
  it 'should allow creation if there is employee' do 
    
    delivery   = Delivery.create_by_employee( @admin , {
      :customer_id    => @customer.id,          
      :delivery_address   => "some address",    
      :delivery_date     => Date.new(2012, 12, 15)   
    })
    
    delivery.should be_valid
  end
  
  context "post sales order creation" do
    before(:each) do
      @delivery   = Delivery.create_by_employee( @admin , {
        :customer_id    => @customer.id,          
        :delivery_address   => "some address",    
        :delivery_date     => Date.new(2012, 12, 15)
      })
    end
    
    it 'should not be confirmable if there is no sales item' do
      @delivery.confirm( @admin ) 
      @delivery.is_confirmed.should be_false 
    end 
    
    context 'creating delivery with 1 delivery entry ' do
      before(:each) do
        @pending_delivery = @complete_cycle_sales_item.ready 
        
        @quantity_sent = 1 
        if @pending_delivery > 1 
          @quantity_sent = @pending_delivery - 1 
        end
        
        @delivery_entry = DeliveryEntry.create_delivery_entry( @admin, @delivery, @complete_cycle_sales_item,  {
            :quantity_sent => @quantity_sent, 
            :quantity_sent_weight => "#{@quantity_sent * 10}" 
          }) 
      end
      
      it 'should have 1 delivery_entry' do
        @delivery.delivery_entries.count.should == 1 
      end
      
      it 'should be confirmable' do 
        @delivery.confirm( @admin ) 
        @delivery.is_confirmed.should be_true
      end
      
      it 'should not be finalizeable if no confirmation' do
        result = @delivery.finalize( @admin ) 
        result.should be_nil 
        @delivery.is_finalized.should be_false 
      end
      
      context "on delivery confirmation" do
        before(:each) do
          @complete_cycle_sales_item.reload 
          @initial_on_delivery = @complete_cycle_sales_item.on_delivery 
          
          @delivery.confirm( @admin ) 
          @complete_cycle_sales_item.reload 
        end
        
        it 'should add the on_delivery status and deduct the ready status' do
          @final_on_delivery = @complete_cycle_sales_item.on_delivery
          delta = @final_on_delivery  - @initial_on_delivery  
          
          
          delta.should == @quantity_sent
        end
        
        
        it 'should not finalize if there is returned weight, but 0 returned quantity'  do
          @delivery_entry.reload 
          @delivery_entry.update_post_delivery(@admin, {
            :quantity_confirmed => @delivery_entry.quantity_sent , 
            :quantity_returned => 0 ,
            :quantity_returned_weight => '10' ,
            :quantity_lost => 0
          })
          
          @delivery_entry.should_not be_valid 
          
          #  fuck, not fail..
          @delivery.finalize(@admin)
          @delivery.reload 
          @delivery.is_finalized.should be_false
        end
        
        it 'should not finalize if there is 0 returned weight while returned quantity != 0 ' do
          @delivery_entry.reload 
          @delivery_entry.update_post_delivery(@admin, {
            :quantity_confirmed => @delivery_entry.quantity_sent - 1 , 
            :quantity_returned => 1 ,
            :quantity_returned_weight => '0' ,
            :quantity_lost => 0
          })
          
          @delivery_entry.should_not be_valid 
          
          #  fuck, not fail..
          @delivery.finalize(@admin)
          @delivery.reload 
          @delivery.is_finalized.should be_false
        end
        
        
        it 'should not finalize if quantity_sent != quantity_confirmed + quantity return + quantity loss ' do
          @delivery_entry.reload 
          @delivery_entry.update_post_delivery(@admin, {
            :quantity_confirmed => @delivery_entry.quantity_sent , 
            :quantity_returned => 1 ,
            :quantity_returned_weight => '10' ,
            :quantity_lost => 1
          })
          
          @delivery_entry.should_not be_valid 
          
          #  fuck, not fail..
          @delivery.finalize(@admin)
          @delivery.reload 
          @delivery.is_finalized.should be_false 
        end
        
         
        context "FINALIZE: confirm all" do
          before(:each) do
            
            @quantity_confirmed=   @delivery_entry.quantity_sent 
            result = @delivery_entry.update_post_delivery(@admin, {
              :quantity_confirmed => @quantity_confirmed , 
              :quantity_returned => 0 ,
              :quantity_returned_weight => '0' ,
              :quantity_lost => 0 
            })
            result.should be_valid 
            @complete_cycle_sales_item.reload 
            @initial_on_delivery_item = @complete_cycle_sales_item.on_delivery 
            @initial_fulfilled = @complete_cycle_sales_item.fulfilled_order
            
            @delivery.finalize(@admin)  
            @complete_cycle_sales_item.reload 
          end 
          
          it 'should finalize the delivery' do
            @delivery.is_finalized.should be_true 
          end
          
          it 'should increase the fulfilled quantity by the quantity on_delivery ' do
            @final_on_delivery_item = @complete_cycle_sales_item.on_delivery 
            @delivery_entry.reload 
            puts "confirmed quantity: #{@delivery_entry.quantity_confirmed}"
            puts "initial_on_delivery_item: #{@initial_on_delivery_item}"
            puts "final_on_delivery_item  : #{@final_on_delivery_item}"
            delta = @initial_on_delivery_item - @final_on_delivery_item
            delta.should == @quantity_confirmed
          end
          
          it 'should deduct the quantity of confirmed item' do
            @final_fulfilled = @complete_cycle_sales_item.fulfilled_order
            
            delta = @final_fulfilled - @initial_fulfilled
            delta.should == @quantity_confirmed
          end
          
        end # end of "confirm all"
        
        context "FINALIZE: confirm partial, return partial" do
        end # end of "confirm partial, return partial"
        
        context "FINALIZE: confirm none, return partial, lost partial" do
        end # end of "confirm none, return partial, lost partial"
        
        context "FINALIZE: confirm_partial, return none, lost_partial " do
        end # end of "confirm_partial, return none, lost_partial"
      
     
        
        
      end # end of "on delivery confirmation" context
      
    end # context 'creating delivery with 1 delivery entry , including production'
  end
  
  
  # create delivery order 
  # => add delivery entries
  # create delivery order confirmation 
    # => sales return
      # => decide whether it will go to post production (fix) 
      # => or it will go to production  (remake) 
    # => delivery loss 
  
 
  
  
end
