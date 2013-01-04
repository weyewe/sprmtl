require 'spec_helper'

describe Payment do
  before(:each) do
    @admin = FactoryGirl.create(:user, :email => "admin@gmail.com", :password => "willy1234", :password_confirmation => "willy1234")
  
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
    
    @processed_quantity = 20
    @ok_quantity = 18 
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
    
    @total_post_production_1 = 15
    
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
    
    @quantity_returned = 5 
    @quantity_confirmed =   @delivery_entry.quantity_sent - @quantity_returned
    
    puts "quantity_confirmed: #{@quantity_confirmed}"
    puts "quantity_returned: #{@quantity_returned}"
    
    @delivery_entry.update_post_delivery(@admin, {
      :quantity_confirmed => @quantity_confirmed , 
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
  
  it 'should allow payment creation' do
    payment = Payment.create_by_employee(@admin, {
      :payment_method => PAYMENT_METHOD[:bank_transfer],
      :customer_id    => @customer.id , 
      :note           => "Dibayarkan dengan nomor transaksi AC/2323flkajfeaij",
      :amount_paid => "50000"
    })
    
    payment.should be_valid
  end
  
  it 'should not allow confirmation if there is no invoice payment' do
    payment = Payment.create_by_employee(@admin, {
      :payment_method => PAYMENT_METHOD[:bank_transfer],
      :customer_id    => @customer.id , 
      :note           => "Dibayarkan dengan nomor transaksi AC/2323flkajfeaij",
      :amount_paid => "50000"
    })
     
    
    payment.confirm( @admin) 
    payment.is_confirmed.should  be_false 
  end
  
  context 'after creating payment, need to add invoice payment' do
    before(:each) do
      @pending_payment =  @delivery.invoice.confirmed_pending_payment
      @total_sum = ( @pending_payment*0.1 ).to_s
      @payment = Payment.create_by_employee(@admin, {
        :payment_method => PAYMENT_METHOD[:bank_transfer],
        :customer_id    => @customer.id , 
        :note           => "Dibayarkan dengan nomor transaksi AC/2323flkajfeaij",
        :amount_paid => @total_sum
      })
    end
    
    it 'should produce valid payment' do
      puts "$$$$$$$$$$$$$$$$$$$$ checking the pending amount\n"*10
      puts "Pending Amount: #{@delivery.invoice.confirmed_pending_payment.to_s}"
      @payment.should be_valid 
    end
    
    it 'should  allow confirmation if total amount of invoice payments is not 0 and the total sum is equal' do 
      
      invoice_payment = InvoicePayment.create_invoice_payment( @admin,  {
        :invoice_id  => @delivery.invoice.id ,
        :payment_id  => @payment.id ,
        :amount_paid => @total_sum
      } ) 
      
      invoice_payment.should be_valid 
      
      @payment.confirm( @admin) 
      @payment.is_confirmed.should  be_true 
    end 
    
    it 'should  not allow confirmation if total amount of invoice payments is not 0 and the total sum is not equal' do 
      
      invoice_payment = InvoicePayment.create_invoice_payment( @admin,  {
        :invoice_id  => @delivery.invoice.id ,
        :payment_id  => @payment.id ,
        :amount_paid => '10000'
      } ) 
      
      invoice_payment.should be_valid 
      
      @payment.confirm( @admin) 
      @payment.is_confirmed.should  be_false  
    end
  end
  
  
  # WARNING! we haven't checked the validation of single customer 
end
