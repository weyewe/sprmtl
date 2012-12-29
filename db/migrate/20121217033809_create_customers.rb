class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string :name
      t.string :contact_person
      
      t.string :phone 
      t.string :mobile 
      t.string :email 
      t.string :bbm_pin  
      
      t.text :office_address 
      t.text :delivery_address
      t.integer :town_id 
       
      t.boolean :is_deleted, :default  => false  
   

      t.timestamps
    end
  end
end
