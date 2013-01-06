class AppUsersController < ApplicationController
  before_filter :role_required
  
  def new
    @objects = User.active_objects
    @new_object = User.new 
  end
  
  def create
    # HARD CODE.. just for testing purposes 
    # params[:customer][:town_id] = Town.first.id 
    @object = User.create_by_employee(current_user,  params[:user] ) 
    if @object.valid?
      @new_object=  User.new
    else
      @new_object= @object
    end
  end
  
  def edit
    @object = User.find_by_id params[:id] 
  end
  
  def update_app_user
    @object = User.find_by_id params[:user_id] 
    @object.update_by_employee(current_user,  params[:user])
    @has_no_errors  = @object.errors.messages.length == 0
  end
  
  def delete_app_user
    @object = User.find_by_id params[:object_to_destroy_id]
    @object_identifier = @object.name 
    @object.delete(current_user)
  end
end
