class CreateDeliveryEntries < ActiveRecord::Migration
  def change
    create_table :delivery_entries do |t|
      t.integer :creator_id 
      t.integer :sales_item_id 
      
      t.integer :delivery_id  # Surat Jalan 
      t.string  :code 
      
=begin
  quantity_sent is the number of sales item leaving our warehouse
  If there are any missing item (quantity lost) , it is the PIC's fault. 
  
  quantity_confirmed is the number of sales item confirmed to be received by customer
  quantity_returned is the number of sales item returned.. maybe because of it not matching specs
  quantity_lost   => difference of quantity_sent - quantity_confirmed - quantity returned 
  
  quantity_lost + quantity_returned + quantity_confirmed == quantity_sent 
=end
      t.integer     :quantity_sent  , :default => 0 
      t.decimal     :quantity_sent_weight , :precision => 7, :scale => 2 , :default => 0 
      
      
=begin
  After customer approval 
=end
      t.integer     :quantity_confirmed  , :default =>0  # => migrate the on_delivery to fulfilled 
      
      t.integer     :quantity_returned, :default => 0  # => sales_return
      t.decimal     :quantity_returned_weight , :precision => 7, :scale => 2 , :default => 0 
      
      t.integer     :quantity_lost  , :default => 0   # => sales_lost 
       
      
      

      t.boolean :is_confirmed , :default => false 
      t.boolean :is_finalized, :default => false  # finalized
      t.timestamps
    end
  end
end
