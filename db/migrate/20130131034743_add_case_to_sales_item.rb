class AddCaseToSalesItem < ActiveRecord::Migration
  def change
    add_column :sales_items, :case, :integer, :default => SALES_ITEM_CREATION_CASE[:new]
  end
end
