class Role < ActiveRecord::Base
  # attr_accessible :title, :body
  
  def Role.all_selectables
    selectables  =  Role.order("created_at DESC") 
    result = []
    selectables.each do |selectable| 
      result << [ "#{selectable.name}" , 
                      selectable.id ]  
    end
    return result
  end
end
