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
end
