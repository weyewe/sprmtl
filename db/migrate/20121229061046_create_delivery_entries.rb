class CreateDeliveryEntries < ActiveRecord::Migration
  def change
    create_table :delivery_entries do |t|

      t.timestamps
    end
  end
end
