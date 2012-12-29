class CreatePostProductionHistories < ActiveRecord::Migration
  def change
    create_table :post_production_histories do |t|
      t.integer :sales_item_id 
      t.timestamps
    end
  end
end
