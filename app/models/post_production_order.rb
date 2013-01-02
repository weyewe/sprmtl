class PostProductionOrder < ActiveRecord::Base
  attr_accessible :sales_item_id, :case, :quantity, 
                  :source_document_entry, :source_document_entry_id,
                  :source_document, :source_document_id
                  
  belongs_to :sales_item 
  
  def PostProductionOrder.create_machining_only_sales_production_order( sales_item )
    PostProductionOrder.create(
      :sales_item_id            => sales_item.id                                               , 
      :case                     =>  POST_PRODUCTION_ORDER[:sales_order_only_post_production]   ,
      :quantity                 => sales_item.quantity                                         ,
      :source_document_entry    => sales_item.class.to_s                                       ,
      :source_document_entry_id => sales_item.id                                               ,
      :source_document          => sales_item.sales_order.class.to_s                           ,
      :source_document_id       => sales_item.sales_order_id 
    ) 
  end
  
  
  def PostProductionOrder.generate_sales_post_production_order( production_history) 
    PostProductionOrder.create(
      :sales_item_id            => production_history.sales_item_id      ,
      :case                     =>  POST_PRODUCTION_ORDER[:sales_order]  ,
      :quantity                 => production_history.ok_quantity +   
                                  production_history.repairable_quantity     ,
      :source_document_entry    => production_history.class.to_s         ,
      :source_document_entry_id => production_history.id                 ,
      :source_document          => production_history.class.to_s         ,
      :source_document_id       => production_history.id                 
    )                                                                    
  end
  
  def PostProductionOrder.generate_production_repair_post_production_order( production_history )
    PostProductionOrder.create(
      :sales_item_id            => production_history.sales_item_id      ,
      :case                     =>  POST_PRODUCTION_ORDER[:production_repair]  ,
      :quantity                 => production_history.repairable_quantity, 
      :source_document_entry    => production_history.class.to_s         ,
      :source_document_entry_id => production_history.id                 ,
      :source_document          => production_history.class.to_s         ,
      :source_document_id       => production_history.id                 
    )
  end
  
  def PostProductionOrder.generate_sales_return_repair_post_production_order( sales_return_entry )
    # puts "\n$$$$$$$$$$$$$$$$$$$$ called from post production order: sales return repair \n"
    ppo = PostProductionOrder.create(
      :sales_item_id            => sales_return_entry.delivery_entry.sales_item_id      ,
      :case                     =>  POST_PRODUCTION_ORDER[:sales_return_repair]  ,
      :quantity                 => sales_return_entry.quantity_for_post_production, 
      
      :source_document_entry    => sales_return_entry.class.to_s          ,
      :source_document_entry_id => sales_return_entry.id                  ,
      :source_document          => sales_return_entry.sales_return.class.to_s          ,
      :source_document_id       => sales_return_entry.sales_return_id
    )
    
    # if ppo.valid?
    #   puts "ppo is valid... the quantity: #{ppo.quantity}"
    #   puts "The sales item id: #{ppo.sales_item_id}"
    # else
    #   puts "ppo is NOT valid "
    # end
  end
  
end
