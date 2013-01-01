class CreateSalesReturnEntries < ActiveRecord::Migration
  def change
    create_table :sales_return_entries do |t|
      
      t.integer :sales_item_id
       
      t.integer :creator_id
      t.integer :sales_return_id 
      t.integer :delivery_entry_id
      
      t.integer :quantity_for_post_production  ,  :default => 0 
      t.decimal :weight_for_post_production  , :precision => 7, :scale => 2 , :default => 0 
      
      t.integer :quantity_for_production       ,  :default => 0 
      t.decimal :weight_for_production , :precision => 7, :scale => 2 , :default => 0 
      

      t.integer :is_confirmed , :default => false
      t.integer :confirmer_id 
      t.datetime :confirmed_at 
      
      t.timestamps
    end
  end
end
