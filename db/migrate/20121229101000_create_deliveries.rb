class CreateDeliveries < ActiveRecord::Migration
  def change
    create_table :deliveries do |t|
      t.string  :code 
      
      t.integer     :creator_id 
      t.integer     :customer_id 
      
      t.text        :delivery_address 
      t.date        :delivery_date
      


      

      # confirmed means that the goods are ready to leave the office.
      # the employee holds full responsibility for it
      t.boolean :is_confirmed, :default => false 
      t.integer :confirmer_id 
      t.datetime  :confirmed_at 


      # finalized means that the customer approved,
      # sales return is declared, and delivery lost is declared as well
      t.boolean     :is_finalized, :default => false   
      t.integer     :finalizer_id 
      t.datetime    :finalized_at 

      

      t.timestamps
    end
  end
end
