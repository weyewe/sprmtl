class BanksController < ApplicationController
  before_filter :role_required
end
