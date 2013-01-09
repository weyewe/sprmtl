class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.integer :delivery_id
      t.integer :creator_id 
      t.integer :customer_id
      
      
      t.string :code 
      t.decimal :amount_payable , :precision   => 11, :scale => 2 , :default => 0  # 10^9 << max value => 999,999,999,999
      # when it is due date (jatuh tempo)
      t.date  :due_date 
      
      # delivery cost? 
      # if it is confirmed => can be printed => set the due date 
      t.boolean :is_confirmed, :default => false 
      t.integer :confirmer_id 
      t.datetime :confirmed_at 
      
      
      # just a guard  => when delivery cost is finalized
      t.boolean :is_finalized, :default => false 
      
       
      
      t.boolean :is_paid, :default => false 
      t.integer :paid_declarator_id
      t.datetime :paid_at 
      
      t.timestamps
    end
  end
end
