class DeliveryLost < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :delivery 
  
end