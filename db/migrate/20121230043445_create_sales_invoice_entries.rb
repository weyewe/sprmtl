class CreateSalesInvoiceEntries < ActiveRecord::Migration
  def change
    create_table :sales_invoice_entries do |t|

      t.timestamps
    end
  end
end
