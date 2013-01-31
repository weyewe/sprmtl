class AddAssociationBetweenSubcriptionHistoryAndHistory < ActiveRecord::Migration
  def up
    add_column :pre_production_histories, :subcription_pre_production_history_id , :integer 
    add_column :production_histories, :subcription_production_history_id , :integer 
    add_column :post_production_histories, :subcription_post_production_history_id , :integer 
    
    add_column :sales_items, :template_sales_item_id, :integer 
    add_column :sales_items, :customer_id, :integer 
    add_column :sales_items, :sales_item_subcription_id, :integer 
  end

  def down
    remove_column :pre_production_histories, :subcription_pre_production_history_id 
    remove_column :production_histories, :subcription_production_history_id 
    remove_column :post_production_histories, :subcription_post_production_history_id
    remove_column :sales_items, :template_sales_item_id 
    remove_column :sales_items, :customer_id  
    remove_column :sales_items, :sales_item_subcription_id  
  end
end
