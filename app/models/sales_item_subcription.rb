class SalesItemSubcription < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :customer
  belongs_to :template_sales_item  
  has_many :sales_items 
  has_many :production_orders # , :post_production_orders
  
  validates_presence_of :customer_id, :template_sales_item_id 
  
  def self.create_subcription(sales_item)
    new_object=  self.new
    new_object.customer_id = sales_item.customer_id 
    new_object.template_sales_item_id = sales_item.template_sales_item_id
    new_object.save 
    return new_object 
  end
end
