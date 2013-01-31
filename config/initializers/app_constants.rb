COMPANY_NAME = "Super Metal"
COMPANY_MOTO = "Super Metal"

COMPANY_DESCRIPTION= 'Production & Payment Management'
LOCAL_TIME_ZONE = "Jakarta" 


USER_ROLE = {
  :admin => "Admin",
  # create new user 
    # assign role to the user  
  
  
  :purchasing => "Purchasing", 
  # new item 
  # create purchase order to add item stock
  # add the recommended selling price 
  
  :inventory => "Inventory", # this sales can do 2 things: consumer sales and business sales. fuck it.
  # => when she is doing consumer sales, she pick: which warehouse ? 
  :sales => "Sales", 
  
  # 
  # :business_sales => "BusinessSales", 
  # # doing sales as well, but with delivery address. 
  # 
  # :consumer_sales => "ConsumerSales"
  # # purely doing sales, give sales price and that's it, give the item to the client 
  # # the item deducted will be from the store she is attached to 
  :mechanic => "Mechanic"
}

 

DEV_EMAIL = "w.yunnal@gmail.com"

TRUE_CHECK = 1
FALSE_CHECK = 0

PROPOSER_ROLE = 0 
APPROVER_ROLE = 1 

IMAGE_ASSET_URL = {
  
  # MSG BOX
  :alert => 'http://s3.amazonaws.com/salmod/app_asset/msg-box/alert.png',
  :background => 'http://s3.amazonaws.com/salmod/app_asset/msg-box/background.png',
  :confirm => 'http://s3.amazonaws.com/salmod/app_asset/msg-box/confirm.png',
  :error => 'http://s3.amazonaws.com/salmod/app_asset/msg-box/error.png',
  :info => 'http://s3.amazonaws.com/salmod/app_asset/msg-box/info.png',
  :question => 'http://s3.amazonaws.com/salmod/app_asset/msg-box/question.png',
  :success => 'http://s3.amazonaws.com/salmod/app_asset/msg-box/success.png',
  
  
  # FONT 
  :font_awesome_eot => 'http://s3.amazonaws.com/salmod/app_asset/font/fontawesome-webfont.eot',
  :font_awesome_svg => 'http://s3.amazonaws.com/salmod/app_asset/font/fontawesome-webfont.svg',
  :font_awesome_svgz =>'http://s3.amazonaws.com/salmod/app_asset/font/fontawesome-webfont.svgz',
  :font_awesome_ttf => 'http://s3.amazonaws.com/salmod/app_asset/font/fontawesome-webfont.ttf',
  :font_awesome_woff => 'http://s3.amazonaws.com/salmod/app_asset/font/fontawesome-webfont.woff',  
  
  
  # BOOTSTRAP SPECIFIC 
  :glyphicons_halflings_white => 'http://s3.amazonaws.com/salmod/app_asset/bootstrap/glyphicons-halflings-white.png',
  :glyphicons_halflings_black => 'http://s3.amazonaws.com/salmod/app_asset/bootstrap/glyphicons-halflings.png',
  
  # jquery UI-lightness 
  :ui_bg_diagonal_thick_18 => 'http://s3.amazonaws.com/salmod/app_asset/jquery-ui/ui-bg_diagonals-thick_18_b81900_40x40.png',
  :ui_bg_diagonal_thick_20 => 'http://s3.amazonaws.com/salmod/app_asset/jquery-ui/ui-bg_diagonals-thick_20_666666_40x40.png',
  :ui_bg_flat_10 => 'http://s3.amazonaws.com/salmod/app_asset/jquery-ui/ui-bg_flat_10_000000_40x100.png' , 
  :ui_bg_glass_100_f6f6f6 => 'http://s3.amazonaws.com/salmod/app_asset/jquery-ui/ui-bg_glass_100_f6f6f6_1x400.png',
  :ui_bg_glass_100 => 'http://s3.amazonaws.com/salmod/app_asset/jquery-ui/ui-bg_glass_100_fdf5ce_1x400.png',
  :ui_bg_glass_65 => 'http://s3.amazonaws.com/salmod/app_asset/jquery-ui/ui-bg_glass_65_ffffff_1x400.png',
  :ui_bf_gloss_wave => 'http://s3.amazonaws.com/salmod/app_asset/jquery-ui/ui-bg_gloss-wave_35_f6a828_500x100.png',
  :ui_bg_highlight_soft_100 => 'http://s3.amazonaws.com/salmod/app_asset/jquery-ui/ui-bg_gloss-wave_35_f6a828_500x100.png',
  :ui_bg_highlight_soft_75 => 'http://s3.amazonaws.com/salmod/app_asset/jquery-ui/ui-bg_highlight-soft_75_ffe45c_1x100.png',
  :ui_icons_222222 => 'http://s3.amazonaws.com/salmod/app_asset/jquery-ui/ui-icons_222222_256x240.png',
  :ui_icons_228ef1 => 'http://s3.amazonaws.com/salmod/app_asset/jquery-ui/ui-icons_228ef1_256x240.png',
  :ui_icons_ef8c08 => 'http://s3.amazonaws.com/salmod/app_asset/jquery-ui/ui-icons_ef8c08_256x240.png',
  :ui_icons_ffd27a => 'http://s3.amazonaws.com/salmod/app_asset/jquery-ui/ui-icons_ffd27a_256x240.png',
  :ui_icons_ffffff => 'http://s3.amazonaws.com/salmod/app_asset/jquery-ui/ui-icons_ffffff_256x240.png',
  :ui_bg_highlight_soft_100_eeeeee => 'http://s3.amazonaws.com/salmod/app_asset/jquery-ui/ui-bg_highlight-soft_100_eeeeee_1x100.png',
  
  
  # APP_APPLICATION.css 
  :jquery_handle => 'http://s3.amazonaws.com/salmod/app_asset/app_application/handle.png',
  :jquery_handle_vertical => 'http://s3.amazonaws.com/salmod/app_asset/app_application/handle-vertical.png',
  :login_bg => 'http://s3.amazonaws.com/salmod/app_asset/app_application/login-bg.png',
  :user_signin => 'http://s3.amazonaws.com/salmod/app_asset/app_application/user.png',
  :password => 'http://s3.amazonaws.com/salmod/app_asset/app_application/password.png',
  :password_error => 'http://s3.amazonaws.com/salmod/app_asset/app_application/password_error.png',
  :check_signin => 'http://s3.amazonaws.com/salmod/app_asset/app_application/check.png',
  :twitter => 'http://s3.amazonaws.com/salmod/app_asset/app_application/twitter_btn.png',
  :fb_button => 'http://s3.amazonaws.com/salmod/app_asset/app_application/fb_btn.png',
  :validation_error => 'http://s3.amazonaws.com/salmod/app_asset/app_application/validation-error.png',
  :validation_success => 'http://s3.amazonaws.com/salmod/app_asset/app_application/validation-success.png',
  :zoom => 'http://s3.amazonaws.com/salmod/app_asset/app_application/zoom.png',
  :logo => 'http://s3.amazonaws.com/salmod/app_asset/app_application/logo.png' 
}


=begin
  ITEM CONSTANT
=end
# MATERIAL     = {
#   :steel     => {
#     :value   => 1, 
#     :name    => "Steel" 
#   } ,
#   :copper    =>  {
#     :value   => 2, 
#     :name    => "Tembaga"
#   }, 
#   :alumunium => {
#     :value   => 3, 
#     :name    => "Aluminium"
#   }
# }

MATERIAL = {
  :alumunium => "Alumunium",
  :copper   => 'Copper',
  :iron => "Iron"
}


=begin
  PRODUCTION RELATED
=end


PRODUCTION_ORDER = {
  :sales_order             => 1,  
  :production_failure      => 2, 
  :post_production_failure => 3, 
  :sales_return            => 4, 
  :delivery_lost           => 5,
  :sales_return_post_production_failure => 10  ,
  
  :guarantee_return => 15

}

POST_PRODUCTION_ORDER = {
  :sales_order_only_post_production => 1,  # so the guy put the iron @us. 
  :sales_order                      => 2,
  :production_repair                => 3, 
  :sales_return_repair              => 4,
  
  :guarantee_return => 15
}

RECYCLE_ORDER  = {
  :production_failure      => 1, 
  :post_production_failure => 2,
  :sales_return         => 3   # returned, can't be fixed at all. fuck.  recycle 
}

RESPONSIBILITY = {
  :pre_production_staff   => 1,
  :pre_production_qc     => 2 ,
  
  :production_staff      => 11,
  :production_qc         => 12, 
  
  :post_production_staff => 11,
  :post_production_qc    => 12, 
  
  :delivery_staff        => 21, 
  :delivery_qc           => 22, 
  
  :sales_return_qc      => 31 

}
 
 
=begin
  PAYMENT RELATED
=end
 
PAYMENT_TERM = {
  :cash                    => 1,  # paid in advance
  :credit                  => 2, # create invoice on delivery 
  :credit_with_downpayment => 3  # partially paid in advance, will be deducted at the end of the term
}

PAYMENT_METHOD = {
  :bank_transfer => 1, 
  :cash => 2, 
  :giro => 3 
}

# CASH_ACCOUNT_CASE = {
#   :bank => 1, 
#   :cash => 2 
# } 

PAYMENT_METHOD_CASE = {
  :bank_transfer => {
    :value => 1 , 
    :name => "Bank Transfer"
  },
  :cash => {
    :value => 2, 
    :name => "Cash"
  },
  :giro => {
    :value => 3, 
    :name => "Giro"
  },
  :only_downpayment => {
    :value => 4, 
    :name => "Hanya Menggunakan Downpayment"
  }
}

DOWNPAYMENT_CASE  = {
  :addition => 1 , 
  :deduction => 2 
}

CASH_ACCOUNT_CASE = {
  :bank           => {
    :value        => 1, 
    :name         => "Bank" 
  } ,
  :cash           =>  {
    :value        => 2, 
    :name         => "Cash"
  } 
}


DELIVERY_ENTRY_CASE = {
  :ready_production                  => 1 , 
  :ready_post_production             => 2, 
  :guarantee_return                  => 11 ,
  :bad_source_fail_post_production   => 21, 
  :technical_failure_post_production => 22  
}

DELIVERY_ENTRY_CASE_VALUE = {
  :ready_production                  =>  "Selesai Cast", 
  :ready_post_production             => "Selesai Bubut", 
  :guarantee_return                  => "Retur Garansi" ,
  :bad_source_fail_post_production   => "Cast Keropos (hanya bubut)", 
  :technical_failure_post_production => "Gagal bubut (hanya bubut)"  
}

# http://www.mangareader.net/303-55068-12/drifters/chapter-14.html

=begin
    CASE 1: if there is only production: 
  1. Sending out the ready production 
  
    Case 2: if there is production + post production 
  2. Sending out the ready post production  ( billed for production + post production )
  3. Sending out the ready production       ( billed only for production ).. not recommended. but, maybe the 
    customer need it so much. So, just give it out.. not billed for it. 
  
    Case 3: if the customer do Guarantee Return 
  4. We receive the Guarantee Return. Fix it. Send it out as the Guarantee Return => Free of Charge
  
    Case 5. only post production 
    The customer sends the cast to us. We have to perform machining on it 
  5.Failure because the cast is in deep shite
    bad_source_fail_post_production (billed for the post production work)
    
  6.Failure because of Company's fault 
    technical_failure_post_production  => policy is unclear. for now.
    Probability of this happening ~> near 0
    Possible reconciliation: free of charge + reimburse? no idea 
    # handle it later. 
    
# pending post_production => can be because it is waiting for fix from sales return, or it is 
=end


ROLE_NAME = {
  :admin => "admin",
  :data_entry => "dataentry"
}

=begin
PRINTING RELATED
=end
CONTINUOUS_FORM_WIDTH = 792
HALF_CONTINUOUS_FORM_LENGTH = 342
FULL_CONTINUOUS_FORM_LENGTH = 684




SALES_ITEM_CREATION_CASE= {
  :new =>   1,
  :repeat =>  2 , 
  :generic => 3
}
