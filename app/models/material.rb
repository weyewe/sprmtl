class Material < ActiveRecord::Base
  attr_accessible :name, :code 
  
  validates_presence_of :name  
  
  def self.active_objects
    self.where(:is_active => true).order("created_at DESC")
  end
  
  def self.all_selectables
    selectables  =  self.active_objects 
    result = []
    selectables.each do |selectable| 
      result << [ "#{selectable.name}" , 
                      selectable.id ]  
    end
    return result
  end
  
  
  
  def delete
    self.is_active = false
    self.save 
  end
end
