class AddDeliveryEntryCaseToDeliveryEntry < ActiveRecord::Migration
  def change
    add_column :delivery_entries, :entry_case, :integer, :default => nil 
  end
end
