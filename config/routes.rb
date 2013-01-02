Supermetal::Application.routes.draw do
  devise_for :users
  devise_scope :user do
    get "sign_in", :to => "devise/sessions#new"
  end

  root :to => 'home#index'
  
  resources :customers
  resources :materials
  
  resources :sales_orders do 
    resources :sales_items 
  end
  
  resources :sales_items do 
    resources :pre_production_histories
    resources :production_histories
    resources :post_production_histories
  end
  resources :pre_production_histories
  resources :production_histories
  resources :post_production_histories
  
  
=begin
  SEARCH DATA
=end
  match 'search_customer' => "customers#search_customer", :as => :search_customer 
  match 'search_sales_item' => "sales_items#search_sales_item", :as => :search_sales_item 
 
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
######### SALES_ORDER
##################################################
##################################################
  match 'update_sales_order/:sales_order_id' => 'sales_orders#update_sales_order', :as => :update_sales_order , :method => :post 
  match 'delete_sales_order' => 'sales_orders#delete_sales_order', :as => :delete_sales_order , :method => :post
  match 'confirm_sales_order/:sales_order_id' => "sales_orders#confirm_sales_order", :as => :confirm_sales_order, :method => :post 


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
end
