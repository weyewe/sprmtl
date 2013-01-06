require 'navigation_helper.rb'
module ApplicationHelper
  include NavigationHelper
  ACTIVE = 'active'
  
  def print_money(value)
    if value.nil?
      number_with_delimiter( 0 , :delimiter => "." )
    else
      number_with_delimiter( value.to_i , :delimiter => "." )
    end 
  end 
  
  def get_checkbox_value(checkbox_value )
    if checkbox_value == true
      return TRUE_CHECK
    else
      return FALSE_CHECK
    end
  end
  
  
=begin
BREADCRUMB
=end
  def create_breadcrumb(breadcrumbs)
    
    if (  breadcrumbs.nil? ) || ( breadcrumbs.length ==  0) 
      # no breadcrumb. don't create 
    else
      breadcrumbs_result = ""
      breadcrumbs_result << "<ul class='breadcrumb'>"
      
      puts "After the first"
      
      
      breadcrumbs[0..-2].each do |txt, path|
        breadcrumbs_result  << create_breadcrumb_element(    link_to( txt, path ) ) 
      end 
      
      puts "After the loop"
      
      last_text = breadcrumbs.last.first
      last_path = breadcrumbs.last.last
      breadcrumbs_result << create_final_breadcrumb_element( link_to( last_text, last_path)  )
      breadcrumbs_result << "</ul>"
      return breadcrumbs_result
    end
    
    
  end
  
  def create_breadcrumb_element( link ) 
    element = ""
    element << "<li>"
    element << link
    element << "<span class='divider'>/</span>"
    element << "</li>"
    
    return element 
  end
  
  def create_final_breadcrumb_element( link )
    element = ""
    element << "<li class='active'>"
    element << link 
    element << "</li>"
    
    return element
  end
  
=begin
  DATE TIME UTILITY
=end

  def print_date(datetime)
    if datetime.nil? 
      return "N/A"
    else
      return "#{datetime.day}/#{datetime.month}/#{datetime.year}"
    end
  end
  
  def print_date_input(datetime)
    if datetime.nil? 
      return ""
    else
      return "#{datetime.day}/#{datetime.month}/#{datetime.year}"
    end
  end
  
  
=begin
  MATERIAL SELECTION
=end
  def all_selectable_materials
    categories  = Category.order("depth  ASC ")
    
    # MATERIAL     = {
    #   :steel     => {
    #     :value   => 1, 
    #     :name    => "Steel" 
    #   } ,
    #   :copper    =>  {
    #     :value   => 2, 
    #     :name    => "Tembaga"
    #   }, 
    #   :alumunium => {
    #     :value   => 3, 
    #     :name    => "Aluminium"
    #   }
    # }
    # 
    
    result = []
    MATERIAL.each do |material| 
      result << [ "#{category.name}" , 
                      category.id ]  
    end
    return result
  end
 
  
end 