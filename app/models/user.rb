class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body
  
  
  
  def self.create_main_user(new_user_params) 
    new_user = User.create( :email => new_user_params[:email], 
                            :password => new_user_params[:password],
                            :password => new_user_params[:password_confirmation] )
                        
    if not new_user.valid?
      return new_user
    end 
    return new_user 
  end
  
end
