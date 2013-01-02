class CreateSalesOrders < ActiveRecord::Migration
  def change
    create_table :sales_orders do |t|
      
      t.integer :creator_id 
      t.integer :customer_id 
      
      t.string  :code 
      t.date    :order_date 
      t.integer :payment_term , :default => PAYMENT_TERM[:credit]
      
      t.decimal :downpayment_amount , :precision => 11, :scale => 2 , :default => 0
      
      
      t.boolean :is_confirmed , :default => false  
      t.integer :confirmer_id 
      t.datetime :confirmed_at 
      
      t.boolean :is_deleted , :default => false 
      
      t.timestamps
    end
  end
end
