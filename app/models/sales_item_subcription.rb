class SalesItemSubcription < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :customer
  belongs_to :template_sales_item  
  has_many :sales_items 
  has_many :production_orders # , :post_production_orders
  has_many :subcription_pre_production_histories
  has_many :subcription_production_histories
  has_many :subcription_post_production_histories
  
  
  validates_presence_of :customer_id, :template_sales_item_id 
  
  def self.create_or_find_subcription(sales_item)
    
    if sales_item.case == SALES_ITEM_CREATION_CASE[:new]
      new_object                        = self.new
      new_object.customer_id            = sales_item.customer_id 
      new_object.template_sales_item_id = sales_item.template_sales_item_id
      new_object.save 
      return new_object 
    else
      return self.where(
        :customer_id => sales_item.customer_id, 
        :template_sales_item_id => sales_item.template_sales_item_id 
      ).first 
    end
  end
  
  
  
  def has_unconfirmed_pre_production_history?
    self.subcription_pre_production_histories.where(:is_confirmed => false ).count != 0 
  end
  
  
  
  
  def has_unconfirmed_post_production_history?
    self.subcription_post_production_histories.where(:is_confirmed => false ).count != 0 
  end
  
=begin
  PENDING PRODUCTION SUMMARY 
=end

  def has_unconfirmed_production_history?
    self.subcription_production_histories.where(:is_confirmed => false ).count != 0 
  end
  
  def pending_production
    self.pending_production_sales_items.sum("pending_production")
  end
  
  def pending_production_sales_items
    self.sales_items.where{
      ( pending_production.gt 0) & 
      ( is_canceled.eq false      ) & 
      ( is_confirmed.eq true      ) &             
      ( is_deleted.eq   false     )               
    }.order("created_at ASC")
  end
  
=begin
  PENDING POST_+ PRODUCTION SUMMARY
=end
  def pending_post_production
    self.pending_post_production_sales_items.sum("pending_post_production")
  end
  
  def pending_post_production_sales_items
    self.sales_items.where{
      ( pending_post_production.gt 0) & 
      ( is_canceled.eq false      ) & 
      ( is_confirmed.eq true      ) &             
      ( is_deleted.eq   false     )               
    }.order("created_at ASC")
  end
end

