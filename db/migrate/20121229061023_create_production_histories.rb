class CreateProductionHistories < ActiveRecord::Migration
  def change
    create_table :production_histories do |t|

      t.timestamps
    end
  end
end
