class CreateSalesEntries < ActiveRecord::Migration
  def change
    create_table :sales_entries do |t|

      t.timestamps
    end
  end
end
