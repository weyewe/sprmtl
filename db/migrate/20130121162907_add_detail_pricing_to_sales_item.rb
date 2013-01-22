class AddDetailPricingToSalesItem < ActiveRecord::Migration
  def change
    add_column :sales_items, :pre_production_price, :decimal, :default  => 0,  :precision => 12, :scale => 2
     
    add_column :sales_items, :production_price, :decimal, :default      => 0,  :precision => 12, :scale => 2
    add_column :sales_items, :post_production_price, :decimal, :default => 0,  :precision => 12, :scale => 2
    
    add_column  :sales_items, :is_pricing_by_weight, :boolean, :default => false  
    
    add_column :sales_items, :is_pending_pricing, :boolean, :default    => false 

    
    remove_column :sales_items, :price_per_piece 
  end
end
