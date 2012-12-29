class CreateDeliveries < ActiveRecord::Migration
  def change
    create_table :deliveries do |t|
      t.integer :creator_id 
      t.integer :delivery_date
      
      t.string  :code 
      t.integer :customer_id  

      t.timestamps
    end
  end
end
