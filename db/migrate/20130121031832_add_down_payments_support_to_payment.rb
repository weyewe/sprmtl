class AddDownPaymentsSupportToPayment < ActiveRecord::Migration
  def change
    add_column  :payments, :downpayment_addition_amount, :decimal, :default => 0,  :precision => 12, :scale => 2
    add_column :payments, :downpayment_usage_amount, :decimal, :default => 0,  :precision => 12, :scale => 2
    
    
    # add_column :payments, :only_using_downpayment, :boolean, :default => false 
    # add_column :payments, :description, :text
  end
end
