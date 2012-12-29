class ApplicationController < ActionController::Base
  include TheRole::Requires
  protect_from_forgery
  
  
  def access_denied
    render :text => 'access_denied: requires an role' and return
  end

  alias_method :login_required,     :authenticate_user!
  alias_method :role_access_denied, :access_denied
    
    
  before_filter :authenticate_user!
  
  layout :layout_by_resource
  def layout_by_resource
    if devise_controller? && resource_name == :user && action_name == 'new'
      "devise"
    else
      "application"
    end
  end
  
  def after_sign_in_path_for(resource)
    # active_job_attachment  = current_user.active_job_attachment 
    # if current_user.has_role?( :branch_manager, active_job_attachment)
    #   puts "user has role branch_manager!\n"*10
    #   return new_group_loan_product_url
    # end
    # 
    # if current_user.has_role?(:loan_officer, active_job_attachment)
    #   puts "user has role loan_officer!\n"*10
    #   return new_member_url
    # end
    # 
    # if current_user.has_role?(:field_worker, active_job_attachment)
    #   puts "user has role field_worker!\n"*10
    #   return select_group_loan_for_weekly_meeting_attendance_marking_url
    # end
    # 
    # if current_user.has_role?(:cashier, active_job_attachment)
    #   puts "user has role field_worker!\n"*10
    #   return select_group_loan_for_loan_disbursement_url
    # end
    
    return root_url 
    
  end
  
  def parse_period_range(service_period_range)
    puts "the content: #{service_period_range}\n"*10
    return nil if params[:service_period_range].nil?
    
    array = service_period_range.split("-").map{|x| x.gsub(' ','')}
    
    start_date = parse_date(array[0])
    end_date   = parse_date(array[1])
    return [start_date, end_date ] 
  end
  
  def parse_date(date)
    date_array = date.split("/")
    return Date.new(date_array[2].to_i,date_array[1].to_i,date_array[0].to_i ) 
  end
  
  
  def set_breadcrumb_for object, destination_path, opening_words 
    add_breadcrumb "#{opening_words}", destination_path
  end

  protected
  def add_breadcrumb name, url = ''
    @breadcrumbs ||= []
    url = eval(url) if url =~ /_path|_url|@/
    @breadcrumbs << [name, url]
  end

  def self.add_breadcrumb name, url, options = {}
    before_filter options do |controller|
      controller.send(:add_breadcrumb, name, url)
    end
  end
  
  
  
end
