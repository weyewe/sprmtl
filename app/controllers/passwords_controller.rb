class PasswordsController < ApplicationController
  skip_before_filter :role_required,  :only => [  
                                                :edit_credential,   
                                                :update 
                                                ]
  def edit_credential
    @user = current_user 
    # @profile = current_user.profile 
    
    # render :layout => 'layouts/settings'
  end

  def update
    @user = current_user

    if @user.update_with_password(params[:user])
      sign_in(@user, :bypass => true)
      flash[:notice] = "Password is updated successfully."
    else
      flash[:error] = "Fail to update password. Check your input!"
    end
    
    @has_no_errors = @user.errors.size == 0 
    
    
  end
end
