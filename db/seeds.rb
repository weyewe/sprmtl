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
admin_role = Role.find_by_name ROLE_NAME[:admin]
first_role = Role.first

data_entry_role = {
  :customers => {
    :new => true,
    :create => true, 
    :edit => true, 
    :update_customer => true ,
    :delete_customer => true  
  },
  :sales_orders => {
    :new => true,
    :create => true, 
    :edit => true, 
    :update_sales_order => true ,
    :delete_sales_order => true ,
    :confirm_sales_order => true 
  },
      :sales_items => {
        :new => true,
        :create => true, 
        :edit => true, 
        :update_sales_item => true ,
        :delete_sales_item => true ,
        :confirm_sales_item => true 
      },
  :pre_production_histories => {
    :new => true,
    :create => true, 
    :edit => true, 
    :update_pre_production_history => true ,
    :delete_pre_production_history => true,
    :confirm_pre_production_history => true
  },
  :production_histories => {
    :new => true,
    :create => true, 
    :edit => true, 
    :update_production_history => true ,
    :delete_production_history => true,
    :confirm_production_history => true
  },
  :post_production_histories => {
    :new => true,
    :create => true, 
    :edit => true, 
    :update_post_production_history => true ,
    :delete_post_production_history => true,
    :confirm_post_production_history => true
  },
  :deliveries => {
    :new => true,
    :create => true, 
    :edit => true, 
    :update_delivery => true ,
    :delete_delivery => true,
    :confirm_delivery => true
  },
      :delivery_entries => {
        :new => true,
        :create => true, 
        :edit => true, 
        :update_delivery_entry => true ,
        :delete_delivery_entry => true,
        :confirm_delivery_entry => true
      },
      
  :sales_returns => {
    :new => true,
    :create => true, 
    :edit => true, 
    :update_sales_return => true ,
    :delete_sales_return => true,
    :confirm_sales_return => true
  },
      :sales_return_entries => {
        :new => true,
        :create => true, 
        :edit => true, 
        :update_sales_return_entry => true ,
        :delete_sales_return_entry => true 
      },
      
  :invoices => {
    :new => true,
    :create => true, 
    :edit => true, 
    :update_invoice => true ,
    :delete_invoice => true,
    :confirm_invoice => true
  }, 
  
  :payments => {
    :new => true,
    :create => true, 
    :edit => true, 
    :update_payment => true ,
    :delete_payment => true,
    :confirm_payment => true
  },
      :invoice_payments => {
        :new => true,
        :create => true, 
        :edit => true, 
        :update_invoice_payment => true ,
        :delete_invoice_payment => true 
      }
}


data_entry_role = Role.create!(
:name        => ROLE_NAME[:data_entry],
:title       => 'Data Entry',
:description => 'Role for data entry',
:the_role    => data_entry_role.to_json
)

admin = User.create_main_user(   :email => "admin@gmail.com" ,:password => "willy1234", :password_confirmation => "willy1234") 

data_entry = User.create_by_employee(admin, {
  :name => "Data Entry",
  :email => "rajakuraemas@gmail.com",
  :role_id => data_entry_role.id 
})
data_entry.password = 'willy1234'
data_entry.password_confirmation = 'willy1234'
data_entry.save

# admin.set_as_main_user


customer_1 = Customer.create :name => "Dixzell"
customer_2 = Customer.create :name => "Bangka Terbang"
copper = Material.create :name => MATERIAL[:copper]
alumunium = Material.create :name => MATERIAL[:alumunium]
iron = Material.create :name => MATERIAL[:iron]

bank_mandiri = CashAccount.create({
  :case =>  CASH_ACCOUNT_CASE[:bank][:value]  ,
  :name => "Bank mandiri 234325321",
  :description => "Spesial untuk non taxable payment"
})

# ADDING SALES ORDER + SALES ITEMS 

sales_order   = SalesOrder.create_by_employee( admin , {
  :customer_id    => customer_1.id,          
  :payment_term   => PAYMENT_TERM[:cash],    
  :order_date     => Date.new(2012, 12, 15)   
})

quantity_in_sales_item = 50 
has_production_sales_item = SalesItem.create_sales_item( admin, sales_order,  {
    :material_id => copper.id, 
    :is_pre_production => true , 
    :is_production     => true, 
    :is_post_production => true, 
    :is_delivered => true, 
    :delivery_address => "Perumahan Citra Garden 1 Blok AC2/3G",
    :quantity => quantity_in_sales_item,
    :description => "Bla bla bla bla bla", 
    :delivery_address => "Yeaaah babyy", 
    :requested_deadline => Date.new(2013, 3,5 ),
    :price_per_piece => "90000", 
    :weight_per_piece   => '15',
    :name => "Nama dari sales item ini ( menurut customer)"
  })
  
puts "BEFORE CONFIRM the sales order code: #{sales_order.code}\n"*10
sales_order.confirm( admin )
puts "AFTER CONFIRM the sales order code: #{sales_order.code}\n"*10



# 
# # ADDING PRE_PRODUCTION 
# pre_production_history =  PreProductionHistory.create_history( admin, has_production_sales_item, {
#   :ok_quantity        =>  5                          ,
#   :broken_quantity    =>  1                          ,
#   :start_date         =>  Date.new(2012,7,14)        ,
#   :finish_date        =>  Date.new(2012,7,20)
# }) 
# pre_production_history.confirm( admin ) 
# 
# 
# # ADDING PRODUCTION 
# production_history =  ProductionHistory.create_history( admin, has_production_sales_item, {
#   :ok_quantity         => 20                            ,
#   :repairable_quantity => 2                             ,
#   :broken_quantity     => 1                             ,
#   :ok_weight           => 200                           ,
#   :repairable_weight   => 20                            ,
#   :broken_weight       => 10                            ,
#   :start_date          => Date.new(2012,8,14)           ,
#   :finish_date         => Date.new(2012,8,21) 
# })
# 
# production_history.confirm( admin )
# 
# # ADDING POST_PRODUCTION 
# post_production_history =  PostProductionHistory.create_history( admin, has_production_sales_item, {
#   :ok_quantity         => 10                           ,
#   :broken_quantity     => 1                            ,
#   :ok_weight           => 90                           ,
#   :broken_weight       => 8                            ,
#   :start_date          => Date.new(2012,10,14)         ,
#   :finish_date         => Date.new(2012,10,25) 
# })
# 
# post_production_history.confirm( admin )
# 
# # ADDING DELIVERY 
# delivery = Delivery.create_by_employee( admin, {
#   :customer_id => customer_1.id ,
#   :delivery_address => "This is delivery address",
#   :delivery_date    => Date.new( 2012,12,12)
# } )  
# 
# has_production_sales_item.reload 
# 
# delivery_entry = DeliveryEntry.create_delivery_entry( admin, delivery,  {
#   :sales_item_id => has_production_sales_item.id ,
#   :quantity_sent => has_production_sales_item.ready - 5,
#   :quantity_sent_weight =>  ((has_production_sales_item.ready - 5)*20).to_s
# } ) 
#  
#  
# delivery.confirm( admin )  
# 
#  

