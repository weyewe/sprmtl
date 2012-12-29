class CreateEmployees < ActiveRecord::Migration
  def change
    create_table :employees do |t|
      t.string :name 
      
      t.string :phone 
      t.string :mobile 
      t.string :email 
      t.string :bbm_pin  
      
      t.text :address  
       
      t.boolean :is_deleted, :default  => false

      t.timestamps
    end
  end
end
