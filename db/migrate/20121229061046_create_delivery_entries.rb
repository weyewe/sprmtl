class CreateDeliveryEntries < ActiveRecord::Migration
  def change
    create_table :delivery_entries do |t|
      t.integer :sales_item_id 

      t.timestamps
    end
  end
end
