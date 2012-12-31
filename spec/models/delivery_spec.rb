require 'spec_helper'

describe Delivery do
  before(:each) do
    @admin = FactoryGirl.create(:user, :email => "admin@gmail.com", :password => "willy1234", :password_confirmation => "willy1234")
  
    
    @customer = FactoryGirl.create(:customer,  :name => "Weyewe",
                                            :contact_person => "Willy" )  
    
    
    # create sales order
    # create sales item
    # confirm sales order 
    # create production history 
    # create post production history 
    # create delivery order 
    # create delivery order confirmation 
      # => sales return
        # => decide whether it will go to post production (fix) 
        # => or it will go to production  (remake) 
      # => delivery loss 
    
  end
 
  
  
end
