class AddGuaranteeBadSourceTechnicalSummaryToSalesItem < ActiveRecord::Migration
  def change
    add_column :sales_items, :pending_guarantee_return_delivery, :integer, :default => 0 
    add_column :sales_items, :pending_bad_source_delivery , :integer , :default => 0 
    add_column :sales_items, :pending_technical_failure_delivery , :integer , :default => 0 
    
    add_column :sales_items, :number_of_guarantee_return, :integer, :default => 0 
    add_column :sales_items, :number_of_bad_source, :integer , :default => 0 
    add_column :sales_items, :number_of_technical_failure , :integer , :default => 0
  end
end
