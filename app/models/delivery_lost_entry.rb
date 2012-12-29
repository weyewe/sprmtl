class DeliveryLostEntry < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :sales_item 
end
