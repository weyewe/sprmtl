class SubcriptionPreProductionHistory < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :sales_item_subcription
end
