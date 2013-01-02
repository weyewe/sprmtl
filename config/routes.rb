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
  
  
=begin
  SEARCH DATA
=end
  match 'search_customer' => "customers#search_customer", :as => :search_customer 
 
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


##################################################
##################################################
######### SALES_ITEM
##################################################
##################################################
  match 'update_sales_item/:sales_item_id' => 'sales_items#update_sales_item', :as => :update_sales_item , :method => :post 
  match 'delete_sales_item' => 'sales_items#delete_sales_item', :as => :delete_sales_item , :method => :post


end
