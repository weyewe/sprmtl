admin = User.create_main_user(   :email => "admin@gmail.com" ,:password => "willy1234", :password_confirmation => "willy1234") 

customer_1 = Customer.create :name => "Dixzell"
customer_2 = Customer.create :name => "Bangka Terbang"


sales_order_1   = SalesOrder.create_by_employee( admin , {
  :customer_id    => customer_1.id,          
  :payment_term   => PAYMENT_TERM[:cash],    
  :order_date     => Date.new(2012, 12, 15)   
})

joko = Employee.create(
  :name => "Joko",
  :address => "Rawa Lele blok 5" 
)

joni = Employee.create(
  :name => "Joni",
  :address => 'Rawa Lele blok 6'
)



# sales item 1 => normal case 
# includes pre production , production , post production, delivery
sales_item_1 = SalesItem.create_sales_item( admin, sales_order_1,  {
  :material_id => MATERIAL[:steel][:value], 
  :is_pre_production => true , 
  :is_production     => true, 
  :is_post_production => true, 
  :is_delivered => true, 
  :delivery_address => "Perumahan Citra Garden 1 Blok AC2/3G",
  :quantity => 50,
  :description => "Bla bla bla bla bla", 
  :delivery_address => "Yeaaah babyy", 
  :requested_deadline => Date.new(2013, 3,5 ),
  :price_per_piece => "90000",
})


sales_order.confirm( admin )

# do the preproduction  # this is just an appendix.. not a KPI in the company-customer info 
PreProductionHistory.create_history( admin, sales_item_1, {
  :quantity_processed       => 10, 
  :quantity_ok              => 5,
  :person_in_charge                      => nil ,# list of employee id 
  :order_date               => Date.new( 2012, 10,10 ) ,
  :finish_date               => Date.new( 2013, 1, 15) 
})


# do the production 
ProductionHistory.create_history( admin, sales_item_1, {
  :processed_quantity    => 10, 
  :ok_quantity           => 8, 
  :repairable_quantity     => 0,
  :broken_quantity       => 2, 
  
  :ok_weight             => '86',  # in kg.. .00 
  :repairable_weight     => '0',
  :broken_weight         => '20',
  
  :person_in_charge      => nil ,# list of employee id 
  :start_date            => Date.new( 2012, 10,10 ) ,
  :finish_date           => Date.new( 2013, 1, 15) 
})

# update number_of_production

# update pending production 
# update pending post production 

# do the post production 
PostProductionHistory.create_history( admin, sales_item_1, {
  :processed_quantity => 8, 
  :ok_quantity        => 5, 
  :broken_quantity    => 3, 
  
  :processed_weight   => 140, 
  :ok_weight          => 86,  # in kg.. .00 
  :broken_weight      => 20,
  
  :person_in_charge   => nil ,# list of employee id 
  :start_date         => Date.new( 2012, 10,10 ) ,
  :finish_date        => Date.new( 2013, 1, 15) 
})
# update pending production 
# update pending post production
# update ready  => ready == 5 

# do the delivery 
delivery = Delivery.create_by_employee( admin , {
  :customer_id        => customer_1.id,       
  :person_in_charge   =>   "#{joni.id},#{joko.id}", 
  :delivery_date      => Date.new( 2013, 2, 15),
  :pic           => "#{joko.id}, #{joni.id}"
})


delivery_entry_1 = DeliveryEntry.create_delivery_entry( admin, delivery,  {
  :sales_item_id =>  sales_item_1.id , 
  :quantity_sent => 2
})

delivery.confirm(admin) 

delivery_entry_1.reload
delivery_entry_1.update_finalization_data( 
  :quantity_confirmed =>2 , 
  :quantity_returned => 0 , 
  :quantity_lost => 0 
) 

delivery_entry_1.finalize( admin ) 




# DON't auto create invoice 
# 


# do the delivery confirmation  
                      # => sales return confirmation   ( instant returned on delivery  ) 
                      # => delivery lost confirmation  ( instant confirmed on delivery )
                        # =>  => invoice adjustment () 
                      
# do the sales return   => instant on delivery 
                        # => independent ( later date )


=begin
  The nature of delivery order and sales invoice
  
  when the item is passed, sales invoice is made
=end


