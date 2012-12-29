class CreateDeliveryLostEntries < ActiveRecord::Migration
  def change
    create_table :delivery_lost_entries do |t|

      t.timestamps
    end
  end
end
