class AddSubcriptionAndAbstractSalesItemAssociationToProductionOrder < ActiveRecord::Migration
  def change
    
    add_column :production_orders, :sales_item_subcription_id, :integer  
    add_column :production_orders, :template_sales_item_id, :integer  
    
    add_column :post_production_orders, :sales_item_subcription_id, :integer  
    add_column :post_production_orders, :template_sales_item_id, :integer
  end
end
