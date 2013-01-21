class CreateDownpaymentHistories < ActiveRecord::Migration
  def change
    create_table :downpayment_histories do |t|

      t.integer :payment_id 
      t.integer :customer_id 
      t.integer :creator_id 
       
      t.decimal :amount,  :default => 0,  :precision => 12, :scale => 2
      
      t.integer :case , :default => DOWNPAYMENT_CASE[:addition]
      
      
      t.timestamps
    end
  end
end
