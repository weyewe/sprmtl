class CreateProductionRepairResults < ActiveRecord::Migration
  def change
    create_table :production_repair_results do |t|

      t.timestamps
    end
  end
end
