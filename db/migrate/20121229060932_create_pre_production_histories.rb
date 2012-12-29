class CreatePreProductionHistories < ActiveRecord::Migration
  def change
    create_table :pre_production_histories do |t|
      t.integer :sales_item_id 
      
      t.integer      :creator_id          
      t.integer      :processed_quantity  
      t.integer      :ok_quantity         
      t.integer      :broken_quantity     
      t.date         :start_date          
      t.date         :finish_date  
     
      
      t.timestamps
    end
  end
end
