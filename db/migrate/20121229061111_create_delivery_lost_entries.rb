class CreateDeliveryLostEntries < ActiveRecord::Migration
  def change
    create_table :delivery_lost_entries do |t|
      
      t.integer :sales_item_id
       
      t.integer :creator_id
      t.integer :delivery_lost_id 
      t.integer :delivery_entry_id
       

      t.integer :is_confirmed , :default => false
      t.integer :confirmer_id 
      t.datetime :confirmed_at

      t.timestamps
    end
  end
end
