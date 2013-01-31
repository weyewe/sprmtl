class CreateSubcriptionPostProductionHistories < ActiveRecord::Migration
  def change
    create_table :subcription_post_production_histories do |t|
      t.integer :sales_item_subcription_id 
      t.integer  :sales_item_id
      t.integer  :creator_id
      t.integer  :processed_quantity           ,          :default => 0
      t.integer  :ok_quantity                  ,          :default => 0
      t.integer  :broken_quantity              ,          :default => 0
      t.decimal  :ok_weight,                              :precision => 7, :scale => 2, :default => 0.0
      t.decimal  :broken_weight,                          :precision => 7, :scale => 2, :default => 0.0
      t.date     :start_date
      t.date     :finish_date
      t.boolean  :is_confirmed,      :default => false
      t.integer  :confirmer_id
      t.datetime :confirmed_at                                                        
      t.integer  :bad_source_quantity,          :default => 0
      t.decimal  :bad_source_weight,                      :precision => 7, :scale => 2, :default => 0.0

      t.timestamps
    end
  end
end
