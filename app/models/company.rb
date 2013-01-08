class Company < ActiveRecord::Base
  attr_accessible :name, :address, :phone 
  validates_presence_of :name 
end
