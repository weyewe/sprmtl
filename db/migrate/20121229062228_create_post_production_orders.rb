class CreatePostProductionOrders < ActiveRecord::Migration
  def change
    create_table :post_production_orders do |t|

      t.timestamps
    end
  end
end
