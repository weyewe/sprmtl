class AddPaymentStatisticToCustomers < ActiveRecord::Migration
  def change
    add_column  :customers, :outstanding_payment, :decimal, :default => 0,  :precision => 12, :scale => 2
    add_column  :customers, :remaining_downpayment, :decimal, :default => 0,  :precision => 12, :scale => 2
  end
end
