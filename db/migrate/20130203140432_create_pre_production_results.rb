class CreatePreProductionResults < ActiveRecord::Migration
  def change
    create_table :pre_production_results do |t|

      t.timestamps
    end
  end
end
