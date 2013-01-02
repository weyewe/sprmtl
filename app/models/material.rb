class Material < ActiveRecord::Base
  attr_accessible :name
  
  validates_presence_of :name 
  
  def self.active_objects
    self.where(:is_active => true).order("created_at DESC")
  end
  
  def delete
    self.is_active = false
    self.save 
  end
end
