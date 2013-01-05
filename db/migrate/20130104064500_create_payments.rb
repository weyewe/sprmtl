class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :creator_id 
      t.integer :cash_account_id 
      
      t.integer :customer_id
      
      t.string :code 
      
      t.decimal :amount_paid , :precision   => 11, :scale => 2 , :default => 0 
      
      t.integer :payment_method  # choose! cash, transfer, or GIRO
      # it can be bank account, petty cash, or cash.. anything 
      # cash_account case => #bank account, #petty_cash, or #cash @office 
      # t.integer :cash_account_id 
      
      t.boolean :is_confirmed, :default => false 
      t.integer :confirmer_id 
      t.datetime :confirmed_at 
      
      t.text :note   # it can be check number, etc
      
      

      t.timestamps
    end
  end
  
  
end
