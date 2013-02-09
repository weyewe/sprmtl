class CreatePostProductionResults < ActiveRecord::Migration
  def change
    create_table :post_production_results do |t|

      t.timestamps
    end
  end
end
