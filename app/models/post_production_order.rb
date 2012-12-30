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
  
end
