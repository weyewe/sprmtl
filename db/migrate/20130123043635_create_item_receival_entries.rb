class CreateItemReceivalEntries < ActiveRecord::Migration
  def change
    create_table :item_receival_entries do |t|
      t.integer :creator_id 
      t.integer :sales_item_id 
      
      t.integer :item_receival_id  # Surat Jalan 
      t.string  :code
      
      t.integer :quantity 
      
      t.boolean :is_confirmed, :default => false 

      t.timestamps
    end
  end
end
