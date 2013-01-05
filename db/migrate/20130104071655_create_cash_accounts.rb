class CreateCashAccounts < ActiveRecord::Migration
  def change
    create_table :cash_accounts do |t|
      
      t.integer :case, :default => CASH_ACCOUNT_CASE[:bank][:value] 
      # bank
      # cash 
      
      t.string  :name 
      
      t.string :description 

      t.timestamps
    end
  end
end
