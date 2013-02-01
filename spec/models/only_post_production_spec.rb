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
    @only_post_production_sales_item = SalesItem.create_sales_item( @admin, @sales_order,  {
        :material_id => @copper.id, 
        :is_pre_production => false , 
        :is_production     => false, 
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
    @only_post_production_sales_item.reload
    @sales_order.reload 
    
    
  end
  
  it 'should confirm sales_order' do
    @sales_order.is_confirmed.should be_true 
    @only_post_production_sales_item.is_confirmed.should be_true 
  end
  
  it 'should create only_post_production sales item' do
    puts "is_post_production: #{@only_post_production_sales_item.is_post_production}"
    puts "is_production: #{@only_post_production_sales_item.is_production}"
    
    @only_post_production_sales_item.only_post_production?.should be_true 
  end
  
  it 'should not create any pending post production ' do
    @only_post_production_sales_item.pending_production.should == 0 
    @only_post_production_sales_item.pending_post_production.should == 0 
  end
    
  context "creating ItemReceival for only post_production" do
    before(:each) do
      @item_receival = ItemReceival.create_by_employee( @admin, {
        :customer_id => @customer.id 
      } ) 
      @received_quantity = 10 
      
      @item_receival_entry = ItemReceivalEntry.create_item_receival_entry( @admin, @item_receival,  {
        :quantity => @received_quantity, 
        :sales_item_id => @only_post_production_sales_item.id
      } ) 
      
      
    end
    
    it 'should have item receival and its entry' do
      @item_receival.should be_valid
      @item_receival_entry.should be_valid 
      @item_receival_entry.item_receival_id.should == @item_receival.id 
    end
    
    context "confirming item receival" do
      before(:each) do
        @initial_pending_post_production = @only_post_production_sales_item.pending_post_production
        @item_receival.confirm(@admin)
        @item_receival.reload
        @item_receival_entry.reload 
        @only_post_production_sales_item.reload 
      end
      
      it 'should confirm item receival'  do
        @item_receival.is_confirmed.should be_true 
        @item_receival_entry.is_confirmed.should be_true 
      end
      
      it 'should increase pending post production by 1: quantity = 10' do
        final_pending_post_production = @only_post_production_sales_item.pending_post_production
        diff = final_pending_post_production - @initial_pending_post_production
        diff.should == @received_quantity
      end
      
      it 'should create post production order with type: sales_order_only_post_production' do
        PostProductionOrder.where(
          :sales_item_id => @only_post_production_sales_item.id ,
          :source_document_entry_id => @item_receival_entry.id, 
          :source_document_entry => @item_receival_entry.class.to_s
        ).first.case.should == POST_PRODUCTION_ORDER[:sales_order_only_post_production]
      end
      
      
      
      
##################################################
############### CASE 1: only_post_production, all successful
##################################################  
      # context "perform post production: all successful" do
      #   before(:each) do
      #     # received_quantity == 10 
      #     @ok_quantity = 5  
      #     @broken_quantity = 0 
      #     @bad_source_quantity = 0 
      #     
      #     @ok_weight = '50'
      #     @broken_weight = '0'
      #     @bad_source_weight = '0'
      #     
      #     @post_production_history = PostProductionHistory.create_history( @admin, @only_post_production_sales_item, {
      #       :ok_quantity           => @ok_quantity, 
      #       :broken_quantity       => @broken_quantity, 
      #       :bad_source_quantity => @bad_source_quantity, 
      # 
      #       :ok_weight             =>  @ok_weight ,  # in kg.. .00 
      #       :broken_weight         =>  @broken_weight ,
      #       :bad_source_weight => @bad_source_weight ,
      # 
      #       # :person_in_charge      => nil ,# list of employee id 
      #       :start_date            => Date.new( 2012, 10,10 ) ,
      #       :finish_date           => Date.new( 2013, 1, 15) 
      #     })
      #   end 
      #   
      #   it 'should produce valid post production history' do
      #     @post_production_history.should be_valid 
      #   end
      #   
      #   context "confirming the post production history" do 
      #     before(:each) do
      #       @only_post_production_sales_item.reload 
      #       @initial_pending_post_production = @only_post_production_sales_item.pending_post_production
      #       @initial_ready = @only_post_production_sales_item.ready 
      #       @post_production_history.confirm(@admin)
      #       @only_post_production_sales_item.reload 
      #     end
      # 
      #     it 'should deduct pending production'  do
      #       final_pending_post_production = @only_post_production_sales_item.pending_post_production
      #       diff = @initial_pending_post_production - final_pending_post_production
      #       diff.should == @ok_quantity 
      #     end
      # 
      #     it 'should add ready item' do
      #       final_ready = @only_post_production_sales_item.ready
      #       diff = final_ready - @initial_ready 
      #       diff.should == @ok_quantity 
      #     end
      #   end # "confirming the post production history"  
      # end
      
      
##################################################
############### CASE 2: only_post_production, bad_source_failure 
# bad_source_failure: return it to the customer. customer pay full $$$ 
##################################################
      context "perform post production:  bad_source failure " do
        before(:each) do
          # received_quantity == 10 
          @ok_quantity = 5  
          @broken_quantity = 0 
          @bad_source_quantity = 2 
          
          @ok_weight = '50'
          @broken_weight = '0'
          @bad_source_weight = '20'
          
          # @post_production_history = PostProductionHistory.create_history( @admin, @only_post_production_sales_item, {
          #   :ok_quantity           => @ok_quantity, 
          #   :broken_quantity       => @broken_quantity, 
          #   :bad_source_quantity => @bad_source_quantity, 
          # 
          #   :ok_weight             =>  @ok_weight ,  # in kg.. .00 
          #   :broken_weight         =>  @broken_weight ,
          #   :bad_source_weight => @bad_source_weight ,
          # 
          #   # :person_in_charge      => nil ,# list of employee id 
          #   :start_date            => Date.new( 2012, 10,10 ) ,
          #   :finish_date           => Date.new( 2013, 1, 15) 
          # })
          
          @only_post_production_sales_item.reload 
          @sales_item_subcription = @only_post_production_sales_item.sales_item_subcription 
          @post_production_history = SubcriptionPostProductionHistory.create_history( @admin, @sales_item_subcription , {
            :ok_quantity             => @ok_quantity           ,
            :bad_source_quantity     => @bad_source_quantity   ,
            :broken_quantity         => @broken_quantity       ,
            :ok_weight               => @ok_weight             ,
            :bad_source_weight       => @bad_source_weight  ,
            :broken_weight           => @broken_weight       ,
            :start_date              => Date.new( 2012, 10,10 )            ,
            :finish_date             => Date.new( 2013, 1, 15)        
          } )
          
          
        end
        
        it 'should create valid post production history' do
          @post_production_history.errors.messages.each do |msg|
            puts "The error: #{msg}"
          end
          @post_production_history.should be_valid 
          @post_production_history.bad_source_quantity.should == @bad_source_quantity
        end
        
        context "before confirming the post production history" do
          before(:each) do
            @only_post_production_sales_item.reload 
            @initial_pending_post_production = @only_post_production_sales_item.pending_post_production
            @initial_ready = @only_post_production_sales_item.ready 
            @post_production_history.confirm(@admin)
            @only_post_production_sales_item.reload 
          end
          
          it 'should deduct the pending post production by ok_quantity and bad_source' do
            final_pending_post_production = @only_post_production_sales_item.pending_post_production
            diff = @initial_pending_post_production - final_pending_post_production
            
            diff.should == @ok_quantity + @bad_source_quantity 
          end
          
          it 'should add ready item' do
            final_ready = @only_post_production_sales_item.ready
            diff = final_ready - @initial_ready 
            diff.should == @ok_quantity 
          end
        end
        
        
      end# "perform post production:  bad_source failure "
      
      
##################################################
############### CASE 3: only_post_production, technical_failure  
# technical_failure: will never happen. output: 
# => 1. Reimburse 
#       # => take the broken piece
#       # => leave the broken piece 
#      
# => 2. Create new one (Production special for the failed shite)
#       # most likely will never happen.. but if it happens.. wtf
##################################################      
      context "perform post production: technical failure" do
        before(:each) do
          # received_quantity == 10 
          @ok_quantity = 5  
          @broken_quantity = 2 
          @bad_source_quantity = 0
          
          @ok_weight = '50'
          @broken_weight = '20'
          @bad_source_weight = '0'
          
          # @post_production_history = PostProductionHistory.create_history( @admin, @only_post_production_sales_item, {
          #   :ok_quantity           => @ok_quantity, 
          #   :broken_quantity       => @broken_quantity, 
          #   :bad_source_quantity => @bad_source_quantity, 
          # 
          #   :ok_weight             =>  @ok_weight ,  # in kg.. .00 
          #   :broken_weight         =>  @broken_weight ,
          #   :bad_source_weight => @bad_source_weight ,
          # 
          #   # :person_in_charge      => nil ,# list of employee id 
          #   :start_date            => Date.new( 2012, 10,10 ) ,
          #   :finish_date           => Date.new( 2013, 1, 15) 
          # })
          
          @only_post_production_sales_item.reload 
          @sales_item_subcription= @only_post_production_sales_item.sales_item_subcription
          @post_production_history = SubcriptionPostProductionHistory.create_history( @admin, @sales_item_subcription , {
            :ok_quantity             => @ok_quantity           ,
            :bad_source_quantity     => @bad_source_quantity   ,
            :broken_quantity         => @broken_quantity       ,
            :ok_weight               => @ok_weight             ,
            :bad_source_weight       => @bad_source_weight  ,
            :broken_weight           => @broken_weight       ,
            :start_date              => Date.new( 2012, 10,10 )            ,
            :finish_date             => Date.new( 2013, 1, 15)        
          } )
          
          
        end
        
        it 'should create valid post production history' do
          @post_production_history.should be_valid 
          @post_production_history.bad_source_quantity.should == @bad_source_quantity
        end
        
        context "before confirming the post production history" do
          before(:each) do
            @only_post_production_sales_item.reload 
            @initial_pending_post_production = @only_post_production_sales_item.pending_post_production
            @initial_ready = @only_post_production_sales_item.ready 
            @post_production_history.confirm(@admin)
            @only_post_production_sales_item.reload 
          end
          
          it 'should deduct the pending post production by ok_quantity and bad_source' do
            final_pending_post_production = @only_post_production_sales_item.pending_post_production
            diff = @initial_pending_post_production - final_pending_post_production
            
            diff.should == @ok_quantity + @broken_quantity 
          end
          
          it 'should add ready item' do
            final_ready = @only_post_production_sales_item.ready
            diff = final_ready - @initial_ready 
            diff.should == @ok_quantity 
          end
        end
      end # "perform post production: technical failure"
      
    end #"confirming item receival" 
    
    
  end # "creating ItemReceival for only post_production" 
   
  
  
  
end
