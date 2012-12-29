class CreateDeliveryLostEntries < ActiveRecord::Migration
  def change
    create_table :delivery_lost_entries do |t|
      t.integer :sales_item_id 

      t.timestamps
    end
  end
end
