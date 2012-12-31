class CreateProductionHistories < ActiveRecord::Migration
  def change
    create_table :production_histories do |t|
      t.integer :sales_item_id
      
      t.integer      :creator_id          
      t.integer      :processed_quantity    # by product ... no real need though..
      
      t.integer      :ok_quantity         
      t.integer      :broken_quantity     
      t.integer      :repairable_quantity   # we don't go for this
      
      t.decimal      :ok_weight         , :precision => 7, :scale => 2 , :default => 0  # 10^5 100 ton
      t.decimal      :broken_weight     , :precision => 7, :scale => 2 , :default => 0  # 10^5
      t.decimal      :repairable_weight , :precision => 7, :scale => 2 , :default => 0  # 10^5
      
      
      
      
      t.date         :start_date          
      t.date         :finish_date
      
      t.boolean :is_confirmed , :default => false 
      t.integer :confirmer_id 
      t.datetime :confirmed_at 

      t.timestamps
    end
  end
end
