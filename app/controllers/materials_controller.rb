class MaterialsController < ApplicationController
  before_filter :role_required
  def new
    @objects = Material.active_objects
    @new_object = Material.new 
  end
  
  def create
    # HARD CODE.. just for testing purposes 
    # params[:customer][:town_id] = Town.first.id 
    @object = Material.create( params[:material] ) 
    if @object.valid?
      @new_object=  Material.new
    else
      @new_object= @object
    end
    
  end
   
  
  def edit
    @object = Material.find_by_id params[:id] 
  end
  
  def update_material
    @object = Material.find_by_id params[:material_id] 
    @object.update_attributes( params[:material])
    @has_no_errors  = @object.errors.messages.length == 0
  end
  
  def delete_material
    @object = Material.find_by_id params[:object_to_destroy_id]
    @object.delete 
  end
end
