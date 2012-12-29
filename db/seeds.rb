admin = User.create_main_user(   :email => "admin@gmail.com" ,:password => "willy1234", :password_confirmation => "willy1234") 

customer_1 = Customer.create :name => "Dixzell"
customer_2 = Customer.create :name => "Bangka Terbang"


sales_order_1   = SalesOrder.create_by_employee( admin , {
  :customer_id    => customer_1.id,          
  :payment_term   => PAYMENT_TERM[:cash],    
  :order_date     => Date.new(2012, 12, 15)   
})


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