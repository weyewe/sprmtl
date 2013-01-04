class CreateInvoicePayments < ActiveRecord::Migration
  def change
    create_table :invoice_payments do |t|
      t.integer :invoice_id 
      t.integer :payment_id 
      t.integer :creator_id
      
      t.decimal :amount_paid , :precision   => 11, :scale => 2 , :default => 0 
      
      
      t.boolean :is_confirmed, :default => false
      t.integer :confirmer_id 
      t.datetime :confirmed_at 
      
      
      t.timestamps
    end
  end
end
