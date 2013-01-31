class CreateSalesItemSubcriptions < ActiveRecord::Migration
  def change
    create_table :sales_item_subcriptions do |t|
      t.integer :template_sales_item_id 
      t.integer :customer_id 
      
      
      
      # the summary from a given customer's item: 
      # find all with the same abstract sales_item_id  and customer id
      # sum the parameters 

      t.timestamps
    end
  end
end
