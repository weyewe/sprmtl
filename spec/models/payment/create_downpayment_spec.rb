require 'spec_helper'

describe "creating downpayment" do
  before(:each) do
    # @admin = FactoryGirl.create(:user, :email => "admin@gmail.com", :password => "willy1234", :password_confirmation => "willy1234")
    role = {
      :system => {
        :administrator => true
      }
    }

    Role.create!(
    :name        => ROLE_NAME[:admin],
    :title       => 'Administrator',
    :description => 'Role for administrator',
    :the_role    => role.to_json
    )
    @admin_role = Role.find_by_name ROLE_NAME[:admin]
    @admin =  User.create_main_user(   :email => "admin@gmail.com" ,:password => "willy1234", :password_confirmation => "willy1234") 
    
  
    @copper = Material.create :name => MATERIAL[:copper]
    @customer = FactoryGirl.create(:customer,  :name => "Weyewe",
                                            :contact_person => "Willy" )
                                            
    @joko = FactoryGirl.create(:employee,  :name => "Joko" )
    @joni = FactoryGirl.create(:employee,  :name => "Joni" )
                                            
    @sales_order   = SalesOrder.create_by_employee( @admin , {
      :customer_id    => @customer.id,          
      :payment_term   => PAYMENT_TERM[:cash],    
      :order_date     => Date.new(2012, 12, 15)   
    })
   
    @bank_mandiri = CashAccount.create({
      :case =>  CASH_ACCOUNT_CASE[:bank][:value]  ,
      :name => "Bank mandiri 234325321",
      :description => "Spesial untuk non taxable payment"
    })
  end 
  
  it 'should be allowed to create Downpayment Addition' do
    downpayment_addition = "500000"
    payment = Payment.create_by_employee(@admin, {
      :payment_method => PAYMENT_METHOD[:bank_transfer],
      :customer_id    => @customer.id , 
      :note           => "Dibayarkan dengan nomor transaksi AC/2323flkajfeaij",
      :amount_paid => "0",
      :cash_account_id => @bank_mandiri.id,
      :downpayment_addition_amount => downpayment_addition,
      :downpayment_usage_amount => "0" 
    })
    
    payment.should be_valid 
  end
  
  context 'after only downpayment addition, payment creation' do
    before(:each) do
      @downpayment_addition = "500000"
      @payment = Payment.create_by_employee(@admin, {
        :payment_method => PAYMENT_METHOD[:bank_transfer],
        :customer_id    => @customer.id , 
        :note           => "Dibayarkan dengan nomor transaksi AC/2323flkajfeaij",
        :amount_paid => "0",
        :cash_account_id => @bank_mandiri.id,
        :downpayment_addition_amount => @downpayment_addition,
        :downpayment_usage_amount => "0" 
      })
      @customer = @payment.customer 
      @initial_remaining_downpayment = @customer.remaining_downpayment
      @payment.confirm(@admin)
      @customer.reload 
    end
     
    it 'should confirm payment' do
      
      puts "The payment is valid " if @payment.valid? 
      puts "The payment is not valid " if not @payment.valid?
      puts "The error size: #{@payment.errors.size}"
      @payment.is_confirmed.should be_true 
    end
     
    it 'should create one downpayment history' do
      @payment.downpayment_histories.count.should == 1 
      downpayment_history  = @payment.downpayment_histories.first 
      downpayment_history.amount.should == BigDecimal("#{@downpayment_addition}")
      downpayment_history.case.should == DOWNPAYMENT_CASE[:addition]
    end
    
    it 'should increase the remaining_downpayment from the customer' do
      @final_remaining_downpayment = @customer.remaining_downpayment
      diff = @final_remaining_downpayment - @initial_remaining_downpayment
      diff.should == BigDecimal("#{@downpayment_addition}")
    end
    
  end
end
