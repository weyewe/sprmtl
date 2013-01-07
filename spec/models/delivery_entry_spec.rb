require 'spec_helper'

describe Delivery do
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
    @delivery   = Delivery.create_by_employee( @admin , {
      :customer_id    => @customer.id,          
      :delivery_address   => "some address",    
      :delivery_date     => Date.new(2012, 12, 15)
    })
    
  end
  
  it 'should not create delivery entry if 0 <  quantity sent  ' do
    @delivery_entry = DeliveryEntry.create_delivery_entry( @admin, @delivery, {
        :quantity_sent => 0 , 
        :quantity_sent_weight => "324",
        :sales_item_id =>  @complete_cycle_sales_item.id 
      })
      
    @delivery_entry.should_not be_valid 
  end
  
  
  it 'should not create delivery entry if  quantity sent > ready ' do 
    @delivery_entry = DeliveryEntry.create_delivery_entry( @admin, @delivery,   {
        :quantity_sent => @complete_cycle_sales_item.ready + 1  , 
        :quantity_sent_weight => "324" ,
        :sales_item_id =>  @complete_cycle_sales_item.id
      })
    @delivery_entry.should_not be_valid
  end
  
  it 'should not create delivery entry if  weight > 0 ' do 
    @delivery_entry = DeliveryEntry.create_delivery_entry( @admin, @delivery,  {
        :quantity_sent => @complete_cycle_sales_item.ready + 1  , 
        :quantity_sent_weight => "-5" ,
        :sales_item_id => @complete_cycle_sales_item.id 
      })
    @delivery_entry.should_not be_valid
    
    
    @delivery_entry = DeliveryEntry.create_delivery_entry( @admin, @delivery,  {
      :quantity_sent => @complete_cycle_sales_item.ready + 1  , 
      :quantity_sent_weight => "0" ,
      :sales_item_id => @complete_cycle_sales_item.id 
      })
    @delivery_entry.should_not be_valid
  end
  
  it 'should not create double delivery entries' do
    second_delivery_quantity = 1
    first_delivery_quantity = @complete_cycle_sales_item.ready - second_delivery_quantity
    @delivery_entry = DeliveryEntry.create_delivery_entry( @admin, @delivery,  {
      :quantity_sent => first_delivery_quantity , 
      :quantity_sent_weight => "#{first_delivery_quantity*10}" ,
      :sales_item_id => @complete_cycle_sales_item.id 
    })
    @delivery_entry.should be_valid
    
    
    @delivery_entry = DeliveryEntry.create_delivery_entry( @admin, @delivery,  {
      :quantity_sent => second_delivery_quantity  , 
      :quantity_sent_weight => "#{second_delivery_quantity*10}" ,
      :sales_item_id => @complete_cycle_sales_item.id 
    })
    @delivery_entry.should_not be_valid
  end
 
  
  
end
