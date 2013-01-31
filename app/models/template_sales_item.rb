class TemplateSalesItem < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :sales_items 
  has_many :sales_item_subcriptions
  has_many :customers, :through => :sales_item_subcriptions 
  has_many :production_orders   # , :post_production_orders
  
  validates_presence_of :code 
  
  def self.create_based_on_sales_item( sales_item )
    new_object = self.new
    new_object.code = sales_item.code 
  
    new_object.save 
    
    return new_object 
  end
  
  def confirmed_sales_items
    self.sales_items.where(:is_confirmed => true ).order("created_at ASC")
  end
end
