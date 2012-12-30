class Delivery < ActiveRecord::Base
  has_many :delivery_entries
   
  
  has_one :sales_invoice
  
  
  
  # attr_accessible :title, :body
end
