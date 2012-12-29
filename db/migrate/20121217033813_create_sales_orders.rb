class CreateSalesOrders < ActiveRecord::Migration
  def change
    create_table :sales_orders do |t|
      
      t.integer :creator_id 
      
      t.string  :code 
      t.date    :order_date 
      t.integer :payment_term , :default => PAYMENT_TERM[:credit]
      
      t.timestamps
    end
  end
end
