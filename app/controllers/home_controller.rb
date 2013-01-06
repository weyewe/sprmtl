class HomeController < ApplicationController
  skip_before_filter :role_required,  :only => [:index, :show]
end
