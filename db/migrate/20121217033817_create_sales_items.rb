class CreateSalesItems < ActiveRecord::Migration
  def change
    create_table :sales_items do |t|
      t.integer :creator_id
      t.integer :sales_order_id 
      
      t.string  :code
      
      t.boolean :is_repeat_order, :default                      => false 
      t.string  :past_sales_item_id   
      
      
      t.integer :material_id  
      
      t.boolean :is_pre_production    ,   :default              => false 
      t.boolean :is_production        ,   :default              => false 
      t.boolean :is_post_production   ,   :default              => false 
      t.boolean :is_delivered         ,   :default              => false 
      
      t.decimal :price_per_piece , :precision                   => 11, :scale => 2 , :default => 0  # 10^9 << max value
      t.decimal :weight_per_piece, :precision => 7, :scale => 2 , :default => 0  
      t.integer :quantity 
      
      
      t.text        :delivery_address 
      t.boolean     :is_sales_order_delivery_address , :default => false 
      # if  it is true, delivery_address can be empty
      t.string      :name 
      t.text        :description 
      
      t.date        :requested_deadline
      t.date        :estimated_internal_deadline 

      
      
      
      
      # statistics  ( internal )
      t.integer :number_of_pre_production             , :default    =>  0  # PreProductionHistory 
      
      
      t.integer :number_of_production                 , :default   =>  0  # ProductionHistory
      t.integer :number_of_post_production            , :default   =>  0  # PostProductionHistory
      t.integer :number_of_delivery                   , :default   =>  0  # DeliveryEntry 
      t.integer :number_of_sales_return               , :default   =>  0  # SalesReturnEntry
      t.integer :number_of_delivery_lost              , :default   =>  0  # DeliveryLostEntry
      t.integer :number_of_failed_production          , :default   =>  0
      t.integer :number_of_failed_post_production     , :default =>  0

                                                
      t.integer :pending_production                , :default =>  0  # ProductionOrder, the work
      t.integer :pending_post_production           , :default =>  0  # PostProductionOrder 
      t.integer :ready                             , :default =>  0 
      t.integer :on_delivery                       , :default =>  0 
      
      # fulfilled order => when it is approved by the customer
      # if there is sales return, deduct the fulfilled order 
      # LAST ONE THAT WE NEED => actual fulfilled order 
      t.integer :fulfilled_order                , :default =>  0 
       
     t.boolean :is_confirmed, :default => false  
     
     t.boolean :is_deleted, :default => false 
     
     # how to declare if it is finished
      
      
=begin
  We need a Document that can be used as the basis for creating each step:
  
  # Pattern
  # add quantity to be done with SPK production (WorkOrder)  => Basis for work to be done
  # add quantity done with Progress Report      (WorkResult)
  
  Preproduction # 
    # => Start with SPK pre production => reason: (hardcoded) 
    
  Production  
    # => Start with SPK production, the basis for SPK production
      # => 1. Sales Order
      # => 2. Sales Return 
      # => 3. Failed Production 
      # => 4. Failed Post Production 
  
  PostProduction
    Work ORder:
      1. Delivery  => delivered or picked up 
      2. Delivery Confirmation  => what if the customer doesn't acknowledge the amount we delivered
=end
      
      # we need something as the basis for creating each step:

      # then, we need something to track progress of each steps
      
      
      # how about history? we need history as well 

      t.timestamps
    end
  end
end
