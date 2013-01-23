class AddPostProductionOnlyColumnsToPostProductionHistory < ActiveRecord::Migration
  def change
    add_column :post_production_histories, :bad_source_quantity, :integer , :default => 0 
    add_column :post_production_histories, :bad_source_weight, :decimal, :precision => 7, :scale => 2 , :default => 0  
  end
end
