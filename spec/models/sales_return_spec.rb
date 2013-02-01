require 'spec_helper'

describe SalesReturn do
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
    
    # creating delivery
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
    
    @delivery_entry = DeliveryEntry.create_delivery_entry( @admin, @delivery, {
        :quantity_sent => @quantity_sent, 
        :quantity_sent_weight => "#{@quantity_sent * 10}" ,
        :sales_item_id =>  @complete_cycle_sales_item.id 
      })
      
    #confirm delivery
    @complete_cycle_sales_item.reload 
    @initial_on_delivery = @complete_cycle_sales_item.on_delivery 
    
    @delivery.confirm( @admin ) 
    @complete_cycle_sales_item.reload 
    @delivery_entry.reload
    
    # create finalization
    @quantity_returned = 5 
    @quantity_confirmed =   @delivery_entry.quantity_sent - @quantity_returned
    
    puts "quantity_confirmed: #{@quantity_confirmed}"
    puts "quantity_returned: #{@quantity_returned}"
    
    @delivery_entry.update_post_delivery(@admin, {
      :quantity_confirmed => @quantity_confirmed , 
      :quantity_confirmed_weight =>  "#{@quantity_confirmed*10 }", 
      :quantity_returned => @quantity_returned ,
      :quantity_returned_weight => "#{@quantity_returned*20}" ,
      :quantity_lost => 0 
    }) 
    
    
    @complete_cycle_sales_item.reload 
    @initial_on_delivery_item = @complete_cycle_sales_item.on_delivery 
    @initial_fulfilled = @complete_cycle_sales_item.fulfilled_order
    
    
    @delivery.reload 
    @delivery.finalize(@admin)
    @delivery.reload
    
    # @delivery.finalize(@admin)  
    @complete_cycle_sales_item.reload
    
  end
  
  it 'should give sales return to delivery' do
    @delivery.is_finalized.should be_true 
    @delivery.sales_return.should be_valid
    
  end
  
  it 'should produce exact copy of returned delivery entry as its sales return entry' do
    sales_return = @delivery.sales_return
    
    sales_return.sales_return_entries.count.should == @delivery.delivery_entries.
                                              where{(quantity_returned.not_eq 0)}.count
    
  end
  
  # deciding the quantity going for production, and the quantity going for post production 
  # go in detail in sales_return_spec => confirming the sales return, produce the shite 
  
  
  
end
