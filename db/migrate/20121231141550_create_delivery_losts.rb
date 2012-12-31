class CreateDeliveryLosts < ActiveRecord::Migration
  def change
    create_table :delivery_losts do |t|

      t.timestamps
    end
  end
end
