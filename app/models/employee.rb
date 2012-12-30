class Employee < ActiveRecord::Base
  attr_accessible :name, :phone, :mobile , 
                  :email, :bbm_pin, :address 
  
  has_many :responsibilities
end
