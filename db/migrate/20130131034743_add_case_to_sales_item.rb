class AddCaseToSalesItem < ActiveRecord::Migration
  def change
    add_column :sales_items, :case, :integer, :default => SALES_ITEM_CREATION_CASE[:new]
    add_column :sales_items, :is_canceled, :boolean, :default => false 
  end
end
