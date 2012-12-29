class CreatePreProductionHistories < ActiveRecord::Migration
  def change
    create_table :pre_production_histories do |t|
      t.integer :sales_item_id 

      t.timestamps
    end
  end
end
