require 'spec_helper'

describe ProductionHistory do
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
    @has_production_sales_item = SalesItem.create_sales_item( @admin, @sales_order,  {
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
  end
  
  it 'should be able to create production history' do
    @has_production_sales_item.should be_valid 
    @sales_order.is_confirmed?.should be_true 
    
    production_history = ProductionHistory.create_history( @admin, @has_production_sales_item, {
      :processed_quantity    => 10, 
      :ok_quantity           => 8, 
      :broken_quantity       => 2, 

      :ok_weight             =>  "#{8*15}" ,  # in kg.. .00 
      # :repairable_weight     => 0,
      :broken_weight         =>  "#{2*10}" ,

      # :person_in_charge      => nil ,# list of employee id 
      :start_date            => Date.new( 2012, 10,10 ) ,
      :finish_date           => Date.new( 2013, 1, 15) 
    })
    
    production_history.should be_valid 
  end
  
  it 'should not allow to create another production history if there is an unconfirmed' do
    production_history = ProductionHistory.create_history( @admin, @has_production_sales_item, {
      :processed_quantity    => 10, 
      :ok_quantity           => 8, 
      :broken_quantity       => 2, 

      :ok_weight             =>  "#{8*15}" ,  # in kg.. .00 
      # :repairable_weight     => 0,
      :broken_weight         =>  "#{2*10}" ,

      # :person_in_charge      => nil ,# list of employee id 
      :start_date            => Date.new( 2012, 10,10 ) ,
      :finish_date           => Date.new( 2013, 1, 15) 
    })
    
    production_history.should be_valid 
    
    second_production_history = ProductionHistory.create_history( @admin, @has_production_sales_item, {
      :processed_quantity    => 10, 
      :ok_quantity           => 8, 
      :broken_quantity       => 2, 

      :ok_weight             =>  "#{8*15}" ,  # in kg.. .00 
      # :repairable_weight     => 0,
      :broken_weight         =>  "#{2*10}" ,

      # :person_in_charge      => nil ,# list of employee id 
      :start_date            => Date.new( 2012, 10,10 ) ,
      :finish_date           => Date.new( 2013, 1, 15) 
    })
    
    second_production_history.should be_nil 
  end
   
  
  context "confirming production history" do
    before(:each) do
      @production_history = ProductionHistory.create_history( @admin, @has_production_sales_item, {
        :processed_quantity    => 10, 
        :ok_quantity           => 8, 
        :broken_quantity       => 2, 

        :ok_weight             =>  "#{8*15}" ,  # in kg.. .00 
        # :repairable_weight     => 0,
        :broken_weight         =>  "#{2*10}" ,

        # :person_in_charge      => nil ,# list of employee id 
        :start_date            => Date.new( 2012, 10,10 ) ,
        :finish_date           => Date.new( 2013, 1, 15) 
      })
      
    end
    
    it 'should be linked to sales item, in association one-to-one' do
      @production_history.sales_item_id.should == @has_production_sales_item.id 
      @production_history.sales_item.id.should == @has_production_sales_item.id 
    end
    
    it 'should not allow confirmation if there is no employee' do
      @production_history.confirm(nil)
      @production_history.is_confirmed?.should be_false 
    end
    
    it 'should  allow confirmation if there is no employee' do
      @production_history.confirm(@admin)
      @production_history.is_confirmed?.should be_true
    end
  end
  
  
end
