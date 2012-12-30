class CreateResponsibilities < ActiveRecord::Migration
  def change
    create_table :responsibilities do |t|
      
      t.integer :entry_id 
      t.integer :case 
      
      

      t.timestamps
    end
  end
end
