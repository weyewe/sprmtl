class AddQuantityConfirmedWeightToDeliveryEntry < ActiveRecord::Migration
  def change
    add_column :delivery_entries, :quantity_confirmed_weight,:decimal, :default => 0,  :precision => 7, :scale => 2
 
  end
end
