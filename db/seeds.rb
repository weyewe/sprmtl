admin = User.create_main_user(   :email => "admin@gmail.com" ,:password => "willy1234", :password_confirmation => "willy1234") 

customer_1 = Customer.create :name => "Dixzell"
customer_2 = Customer.create :name => "Bangka Terbang"