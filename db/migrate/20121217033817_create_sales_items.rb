class CreateSalesItems < ActiveRecord::Migration
  def change
    create_table :sales_items do |t|

      t.timestamps
    end
  end
end
