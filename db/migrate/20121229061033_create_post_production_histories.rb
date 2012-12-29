class CreatePostProductionHistories < ActiveRecord::Migration
  def change
    create_table :post_production_histories do |t|

      t.timestamps
    end
  end
end
