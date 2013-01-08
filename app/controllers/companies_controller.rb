class CompaniesController < ApplicationController
  def edit_main_company
    @company = Company.first
  end
    
  def update_company
    @company = Company.find_by_id params[:id]
    @company.update_attributes(params[:company])
  end
end
