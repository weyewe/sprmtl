class CreateProductionOrders < ActiveRecord::Migration
  def change
    create_table :production_orders do |t|

      t.timestamps
    end
  end
end
