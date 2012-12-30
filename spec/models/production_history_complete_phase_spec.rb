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
  end
  
  it 'should be able to create production history' do
    @complete_cycle_sales_item.should be_valid 
    @sales_order.is_confirmed?.should be_true 
    
    production_history = ProductionHistory.create_history( @admin, @complete_cycle_sales_item, {
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
    production_history = ProductionHistory.create_history( @admin, @complete_cycle_sales_item, {
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
    
    second_production_history = ProductionHistory.create_history( @admin, @complete_cycle_sales_item, {
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
        :repairable_weight     => 13,
        :broken_weight         =>  "#{2*10}" ,

        # :person_in_charge      => nil ,# list of employee id 
        :start_date            => Date.new( 2012, 10,10 ) ,
        :finish_date           => Date.new( 2013, 1, 15) 
      })
      
    end
    
    it 'should be linked to sales item, in association one-to-one' do
      @production_history.sales_item_id.should == @complete_cycle_sales_item.id 
      @production_history.sales_item.id.should == @complete_cycle_sales_item.id 
    end
    
    it 'should not allow confirmation if there is no employee' do
      @production_history.confirm(nil)
      @production_history.is_confirmed?.should be_false 
    end
    
    it 'should  allow confirmation if there is no employee' do
      @production_history.confirm(@admin)
      @production_history.is_confirmed?.should be_true
    end
    
    context "confirming the production history: Interfacing Production vs Post Production" do
      before(:each) do
        @production_history.confirm(@admin)
        @complete_cycle_sales_item.reload 
      end
      
      
      it 'should create post production order quantity equal to the number of ok quantity + repairable quantity' do
        @complete_cycle_sales_item.post_production_orders.count.should ==  1
        @complete_cycle_sales_item.sales_post_production_orders.count.should ==  1
      end
      
      it 'should create production order equal to the number of the broken quantity ' do
        @complete_cycle_sales_item.fail_production_production_orders.count.should == 1 
        @complete_cycle_sales_item.production_orders.count.should == 2 
        
        
        # the first == sales order
        # the second production order == fail_production
      end
      
      # updating the sales item statistics
      it 'should deduct pending production by the ok quantity' do
      end
      
      it 'should add the pending post production by the ok + repairable quantity' do
      end
      
        
      
    end # context "confirming the production history"
  end
  
  
end

# plan for 31st dec => 
# => 1. create the code for post production 
# => 2. create the spec for post production 

# => 3. create the delivery 
  # => 3.1. create the delivery_entry
  
# => 4. create the delivery_confirmation 
  # => 4.1 sales_return generated 
        # => 4.1.1 create repair sales_return post_production order 
        # => 4.1.2 create sales_return production order 
        
  # => 4.2 delivery_loss generated 
        # => create delivery_loss production order

# BY now, assuming that the sales return happens on confirmation.. it is done 

# However, special case: what if the sales return happens later, after the confirmation? 
  # select the delivery order.. create sales return based on that delivery order 
  # to check the amount of saels return, check the sales_return entry, not the sales return @delivery confirmation
  
  
# NOW, the payment..
# on delivery creation => we need to produce invoice. 
  # assuming that it is all by credit 
    # => 1. due payment date (jatuh tempo on the invoice)  => auto reminder for those invoice pass
      # the due payment date 
    # => 2. on payment: bank transfer or giro => to which bank account? 
        # => if bank transfer => auto approve
        # => if GIRO          => pending approval 
        # => if cash          => auto approve 
        
# HOW ABOUT THOSE DOWN PAYMENT MECHANISM? 

# invoice has_many payment_entries  => no.. asking them to select the invoice is crazy
  # => just ask them to specify the amount and method.. the system will perform auto clearance (automated)

# when creating payment => need to confirm.. 
# confirm the payment, ## which invoice is paid first? FIFO? 


# when all payment has been made, and all  deliveries has been made => how can we close the sales order?
# close sales order by manager. 

# corner case: what if there is payment made for certain invoice. Then, there is sales return (not immediate)?
# what will happen to the invoice? there will be excess payment. in the delivery => should not be billed


# NORMAL CASE ===> instant sales return upon delivery confirmation 
# send 5, only receive 2 => the sales invoice is deducted.. only for the 2 received. 

# let's assume that there is no case such as this... the system has to be managed properly. 
  # delivery receipt
# WEIRD CASE ===> DELAYED SALES RETURN.
# send 5, receive 5   => the sales invoice is confirmed... full payment for 5 items

# PROBLEMATIC CASE: sales return replacement 
# but, later on, they find out that it has to be rejected
# according to the system, can't be done. However, our goodwill.. we must be flexible 
# so, retrieve the reject item.. fix or do some shite... 
  #  send it back.. is there invoice included? 
  # in delivery order => specify item quantity 
  # in accompanying invoice => mark as 0 rupiah (sales return replacement delivery) 
  # or, does invoice even needed? 
  
  
# AAAAND, we are DONE! 


