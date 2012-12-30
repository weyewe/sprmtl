class Responsibility < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :employee 
end
