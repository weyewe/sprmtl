class CreateSubcriptionPreProductionHistories < ActiveRecord::Migration
  def change
    create_table :subcription_pre_production_histories do |t|
      t.integer  :sales_item_subcription_id 
      
      t.integer  :creator_id
      t.integer  :processed_quantity   , :default =>  0 
      t.integer  :ok_quantity          , :default =>  0 
      t.integer  :broken_quantity      , :default =>  0 
      t.date     :start_date
      t.date     :finish_date
      t.boolean  :is_confirmed        , :default => false 
      t.integer  :confirmer_id
      t.datetime :confirmed_at
     

      t.timestamps
    end
  end
end
