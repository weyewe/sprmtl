class CreatePreProductionHistories < ActiveRecord::Migration
  def change
    create_table :pre_production_histories do |t|

      t.timestamps
    end
  end
end
