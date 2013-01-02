class CreateDeliveryLosts < ActiveRecord::Migration
  def change
    create_table :delivery_losts do |t|
      t.integer :creator_id
      t.integer :delivery_id  
      
      t.string :code 
      
      
      # when it is confirmed => production order is created. 
      # post production order is created
      t.boolean :is_confirmed, :default => false 
      t.integer :confirmer_id 
      t.integer :confirmed_at
      
      t.timestamps
    end
  end
end
