class CreateCashAccounts < ActiveRecord::Migration
  def change
    create_table :cash_accounts do |t|

      t.timestamps
    end
  end
end
