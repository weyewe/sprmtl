class ProductionOrder < ActiveRecord::Base
  attr_accessible :sales_item_id, :case, :quantity,
                  :source_document_entry, :source_document_entry_id,
                  :source_document, :source_document_id
  belongs_to :sales_item
  
  def ProductionOrder.create_sales_production_order( sales_item  )
      ProductionOrder.create(
        :sales_item_id            => sales_item.id                ,
        :case                     => PRODUCTION_ORDER[:sales_order] ,
        :quantity                 => sales_item.quantity            ,
        :source_document_entry    => sales_item.class.to_s          ,
        :source_document_entry_id => sales_item.id                  ,
        :source_document          => sales_item.sales_order.to_s    ,
        :source_document_id       => sales_item.sales_order_id  
      )
  end
  
  def ProductionOrder.generate_fail_production_production_order( production_history )
    sales_item = production_history.sales_item 
    ProductionOrder.create(
      :sales_item_id            => production_history.sales_item_id       ,
      :case                     => PRODUCTION_ORDER[:fail_production]     ,
      :quantity                 => production_history.broken_quantity     ,

      :source_document_entry    => production_history.class.to_s          ,
      :source_document_entry_id => production_history.id                  ,
      :source_document          => production_history.class.to_s          ,
      :source_document_id       => production_history.id  
    ) 
  end
  
end
