require 'spec_helper'

describe SalesOrder do
  before(:each) do
    @admin = FactoryGirl.create(:user, :email => "admin@gmail.com", :password => "willy1234", :password_confirmation => "willy1234")
  
    
    @willy = FactoryGirl.create(:customer,  :name => "Weyewe",
                                            :contact_person => "Willy" ) 

    
  
  end
  
  it 'should have 1 custumer' do
    
  end
  
  
end
