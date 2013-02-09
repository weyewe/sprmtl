class CreateProductionResults < ActiveRecord::Migration
  def change
    create_table :production_results do |t|

      t.timestamps
    end
  end
end
