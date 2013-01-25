Supermetal::Application.routes.draw do
  devise_for :users
  devise_scope :user do
    get "sign_in", :to => "devise/sessions#new"
  end

  root :to => 'home#index'
  
  resources :customers do
    resources :downpayment_histories 
  end
  resources :materials
  resources :companies 
  match 'edit_main_company' => 'companies#edit_main_company', :as => :edit_main_company, :method => :post 
  match 'update_company/:id' => 'companies#update_company', :as => :update_company, :method => :post 
  
  resources :users
  resources :app_users
  
  resources :sales_orders do 
    resources :sales_items 
  end
  
  resources :item_receivals do
    resources :item_receival_entries 
  end
  
  resources :sales_items do 
    resources :pre_production_histories
    resources :production_histories
    resources :post_production_histories
  end
  resources :pre_production_histories
  resources :production_histories
  resources :post_production_histories
  
  resources :deliveries do
    resources :delivery_entries 
  end
  
  resources :sales_returns do
    resources :sales_return_entries
  end
  
  resources :guarantee_returns do 
    resources :guarantee_return_entries 
  end
  
  resources :invoices 
  
  resources :payments  do
    resources :invoice_payments 
  end
  resources :cash_accounts
  
  
=begin
  SEARCH DATA
=end
  match 'search_customer' => "customers#search_customer", :as => :search_customer 
  match 'search_sales_item' => "sales_items#search_sales_item", :as => :search_sales_item 
 
##################################################
##################################################
######### REPORT_ROUTES 
##################################################
##################################################
  match 'production_details/:sales_item_id' => 'home#production_details', :as => :production_details
  match 'post_production_details/:sales_item_id' => 'home#post_production_details', :as => :post_production_details
  match 'delivery_entry_details/:sales_item_id' => 'home#delivery_entry_details', :as => :delivery_entry_details
  
 
  match 'customers_with_outstanding_payment' => 'home#customers_with_outstanding_payment', :as => :customers_with_outstanding_payment
  match 'outstanding_payment_details/:customer_id' => 'home#outstanding_payment_details', :as => :outstanding_payment_details
=begin
  MASTER DATA ROUTES
=end
 

##################################################
##################################################
######### MATERIAL
##################################################
##################################################
  match 'update_material/:material_id' => 'materials#update_material', :as => :update_material , :method => :post 
  match 'delete_material' => 'materials#delete_material', :as => :delete_material , :method => :post



##################################################
##################################################
######### CUSTOMER
##################################################
##################################################
  match 'update_customer/:customer_id' => 'customers#update_customer', :as => :update_customer , :method => :post 
  match 'delete_customer' => 'customers#delete_customer', :as => :delete_customer , :method => :post


##################################################
##################################################
######### CASH_ACCOUNT
##################################################
##################################################
  match 'update_cash_account/:cash_account_id' => 'cash_accounts#update_cash_account', :as => :update_cash_account , :method => :post 
  match 'delete_cash_account' => 'cash_accounts#delete_cash_account', :as => :delete_cash_account , :method => :post


##################################################
##################################################
######### USER 
##################################################
##################################################
  match 'update_user/:user_id' => 'users#update_user', :as => :update_user , :method => :post 
  match 'delete_user' => 'users#delete_user', :as => :delete_user , :method => :post
  
##################################################
##################################################
######### APP_USER 
##################################################
##################################################
  match 'update_app_user/:user_id' => 'app_users#update_app_user', :as => :update_app_user , :method => :post 
  match 'delete_app_user' => 'app_users#delete_app_user', :as => :delete_app_user , :method => :post

=begin
  SETTING
=end
  match 'edit_credential' => "passwords#edit_credential" , :as => :edit_credential
  match 'update_password' => "passwords#update" , :as => :update_password, :method => :put

##################################################
##################################################
######### SALES_ORDER
##################################################
##################################################
  match 'update_sales_order/:sales_order_id' => 'sales_orders#update_sales_order', :as => :update_sales_order , :method => :post 
  match 'delete_sales_order' => 'sales_orders#delete_sales_order', :as => :delete_sales_order , :method => :post
  match 'confirm_sales_order/:sales_order_id' => "sales_orders#confirm_sales_order", :as => :confirm_sales_order, :method => :post 

  match 'print_sales_order/:sales_order_id' => 'sales_orders#print_sales_order' , :as => :print_sales_order

##################################################
##################################################
######### SALES_ITEM
##################################################
##################################################
  match 'update_sales_item/:sales_item_id' => 'sales_items#update_sales_item', :as => :update_sales_item , :method => :post 
  match 'delete_sales_item' => 'sales_items#delete_sales_item', :as => :delete_sales_item , :method => :post


##################################################
##################################################
######### PRE_PRODUCTION_HISTORY
##################################################
##################################################
  match 'update_pre_production_history/:pre_production_history_id' => 'pre_production_histories#update_pre_production_history', :as => :update_pre_production_history , :method => :post 
  match 'delete_pre_production_history' => 'pre_production_histories#delete_pre_production_history', :as => :delete_pre_production_history, :method => :post
  match 'confirm_pre_production_history/:pre_production_history_id' => "pre_production_histories#confirm_pre_production_history", :as => :confirm_pre_production_history, :method => :post 

  match 'generate_pre_production_history' => 'pre_production_histories#generate_pre_production_history', :as => :generate_pre_production_history, :method => :post 
  
##################################################
##################################################
######### PRODUCTION_HISTORY
##################################################
##################################################
  match 'update_production_history/:production_history_id' => 'production_histories#update_production_history', :as => :update_production_history , :method => :post 
  match 'delete_production_history' => 'production_histories#delete_production_history', :as => :delete_production_history, :method => :post
  match 'confirm_production_history/:production_history_id' => "production_histories#confirm_production_history", :as => :confirm_production_history, :method => :post 

  match 'generate_production_history' => 'production_histories#generate_production_history', :as => :generate_production_history, :method => :post


##################################################
##################################################
######### POST_PRODUCTION_HISTORY
##################################################
##################################################
  match 'update_post_production_history/:post_production_history_id' => 'post_production_histories#update_post_production_history', :as => :update_post_production_history , :method => :post 
  match 'delete_post_production_history' => 'post_production_histories#delete_post_production_history', :as => :delete_post_production_history, :method => :post
  match 'confirm_post_production_history/:post_production_history_id' => "post_production_histories#confirm_post_production_history", :as => :confirm_post_production_history, :method => :post 

  match 'generate_post_production_history' => 'post_production_histories#generate_post_production_history', :as => :generate_post_production_history, :method => :post
  
##################################################
##################################################
######### DELIVERY
##################################################
##################################################
  match 'update_delivery/:delivery_id' => 'deliveries#update_delivery', :as => :update_delivery , :method => :post 
  match 'delete_delivery' => 'deliveries#delete_delivery', :as => :delete_delivery , :method => :post
  match 'confirm_delivery/:delivery_id' => "deliveries#confirm_delivery", :as => :confirm_delivery, :method => :post
  match 'finalize_delivery/:delivery_id' => "deliveries#finalize_delivery", :as => :finalize_delivery, :method => :post
  
  
  match 'print_delivery/:delivery_id' => 'deliveries#print_delivery' , :as => :print_delivery
##################################################
##################################################
######### DELIVERY_ENTRY
##################################################
##################################################
  match 'update_delivery_entry/:delivery_entry_id' => 'delivery_entries#update_delivery_entry', :as => :update_delivery_entry , :method => :post 
  match 'delete_delivery_entry' => 'delivery_entries#delete_delivery_entry', :as => :delete_delivery_entry , :method => :post
  match 'edit_post_delivery_delivery_entry/:delivery_entry_id'  => 'delivery_entries#edit_post_delivery_delivery_entry', :as => :edit_post_delivery_delivery_entry , :method => :get
  match 'update_post_delivery_delivery_entry/:delivery_entry_id'  => 'delivery_entries#update_post_delivery_delivery_entry', :as => :update_post_delivery_delivery_entry , :method => :post
  
  match 'new_special_delivery_entry/:delivery_id' => 'delivery_entries#new_special_delivery_entry', :as => :new_special_delivery_entry 
  match 'create_special_delivery_entry/:delivery_id' => 'delivery_entries#create_special_delivery_entry', :as => :create_special_delivery_entry, :method => :post  
  
  match 'edit_special_delivery_entry/:id' => 'delivery_entries#edit_special_delivery_entry', :as => :edit_special_delivery_entry 
  match 'update_special_delivery_entry/:delivery_entry_id' => 'delivery_entries#update_special_delivery_entry', :as => :update_special_delivery_entry , :method => :post  
  
  
##################################################
##################################################
######### Sales RETURN
##################################################
##################################################
  match 'confirm_sales_return/:sales_return_id' => "sales_returns#confirm_sales_return", :as => :confirm_sales_return, :method => :post
  
##################################################
##################################################
######### Sales RETURN Entry
##################################################
##################################################
  match 'update_sales_return_entry/:sales_return_entry_id' => 'sales_return_entries#update_sales_return_entry', :as => :update_sales_return_entry , :method => :post 
  


##################################################
##################################################
######### Guarantee Return
##################################################
##################################################
  match 'update_guarantee_return/:guarantee_return_id' => 'guarantee_returns#update_guarantee_return', :as => :update_guarantee_return , :method => :post 
  match 'delete_guarantee_return' => 'guarantee_returns#delete_guarantee_return', :as => :delete_guarantee_return , :method => :post
  match 'confirm_guarantee_return/:guarantee_return_id' => "guarantee_returns#confirm_guarantee_return", :as => :confirm_guarantee_return, :method => :post
  # match 'finalize_delivery/:delivery_id' => "deliveries#finalize_delivery", :as => :finalize_delivery, :method => :post
  # 
  # 
  # match 'print_delivery/:delivery_id' => 'deliveries#print_delivery' , :as => :print_delivery
##################################################
##################################################
######### Guarantee Return Entry
##################################################
##################################################
  match 'update_guarantee_return_entry/:guarantee_return_entry_id' => 'guarantee_return_entries#update_guarantee_return_entry', :as => :update_guarantee_return_entry , :method => :post 
  match 'delete_guarantee_return_entry' => 'guarantee_return_entries#delete_guarantee_return_entry', :as => :delete_guarantee_return_entry , :method => :post
  # match 'edit_post_delivery_delivery_entry/:delivery_entry_id'  => 'delivery_entries#edit_post_delivery_delivery_entry', :as => :edit_post_delivery_delivery_entry , :method => :get
  # match 'update_post_delivery_delivery_entry/:delivery_entry_id'  => 'delivery_entries#update_post_delivery_delivery_entry', :as => :update_post_delivery_delivery_entry , :method => :post



##################################################
##################################################
######### Item Receival
##################################################
##################################################
  match 'update_item_receival/:item_receival_id' => 'item_receivals#update_item_receival', :as => :update_item_receival , :method => :post 
  match 'delete_item_receival' => 'item_receivals#delete_item_receival', :as => :delete_item_receival , :method => :post
  match 'confirm_item_receival/:item_receival_id' => "item_receivals#confirm_item_receival", :as => :confirm_item_receival, :method => :post
  
##################################################
##################################################
######### Item Receival Entry
##################################################
##################################################
  match 'update_item_receival_entry/:item_receival_entry_id' => 'item_receival_entries#update_item_receival_entry', :as => :update_item_receival_entry , :method => :post 
  match 'delete_item_receival_entry' => 'item_receival_entries#delete_item_receival_entry', :as => :delete_item_receival_entry , :method => :post
  

##################################################
##################################################
######### Invoice
##################################################
##################################################
  match 'update_invoice/:invoice_id' => 'invoices#update_invoice', :as => :update_invoice , :method => :post 
  match 'confirm_invoice/:invoice_id' => "invoices#confirm_invoice", :as => :confirm_invoice, :method => :post

  match 'print_invoice/:invoice_id' => 'invoices#print_invoice' , :as => :print_invoice


##################################################
##################################################
######### PAYMENT
##################################################
##################################################
  match 'update_payment/:payment_id' => 'payments#update_payment', :as => :update_payment , :method => :post 
  match 'delete_payment' => 'payments#delete_payment', :as => :delete_payment , :method => :post
  match 'confirm_payment/:payment_id' => "payments#confirm_payment", :as => :confirm_payment, :method => :post
  match 'finalize_payment/:payment_id' => "payments#finalize_payment", :as => :finalize_payment, :method => :post


  match 'print_payment/:payment_id' => 'payments#print_payment' , :as => :print_payment
  
   
##################################################
##################################################
######### Invoice Payments
##################################################
##################################################
  match 'update_invoice_payment/:invoice_payment_id' => 'invoice_payments#update_invoice_payment', :as => :update_invoice_payment , :method => :post 
  match 'delete_invoice_payment' => 'invoice_payments#delete_invoice_payment', :as => :delete_invoice_payment , :method => :post

end
