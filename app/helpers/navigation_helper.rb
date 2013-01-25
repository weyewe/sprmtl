
module NavigationHelper 
  ACTIVE_CLASS = "active"
  
   
  
  
  REPORT_NAV = {
    :header => "Report",
    :header_icon => "icon-file", 
    :has_dropdown => true, 
    :only_icon => false , 
    :blocks => [
      # block 1 
      [
        {
          :name => "Progress",
          :url  => 'root_url',
          :icon => "icon-tasks",
          :activities => [
            {
              :controller => "home",
              :action     => "index"
            },
            {
              :controller => "home",
              :action     => "production_details"
            },
            {
              :controller => "home",
              :action     => "post_production_details"
            },
            {
              :controller => "home",
              :action     => "delivery_entry_details"
            }
          ]
        } 
      ],
      [
        {
          :name => "Hutang",
          :url  => 'customers_with_outstanding_payment_url',
          :icon => "icon-tasks",
          :activities => [
            {
              :controller => "home",
              :action     => "customers_with_outstanding_payment"
            },
            {
              :controller => "home",
              :action     => "outstanding_payment_details"
            }
          ]
        } 
      ],
      
      
    ] 
  }
  
  
  MANAGEMENT_NAV = {
    :header => "Management",
    :header_icon => "icon-th", 
    :has_dropdown => true, 
    :only_icon => false , 
    :blocks => [
      # block 1 
      [
        {
          :name => "Cash Account",
          :url  => 'new_cash_account_url',
          :icon => "icon-plus-sign",
          :activities => [
            {
              :controller => "cash_accounts",
              :action     => "new"
            },
            {
              :controller => "",
              :action     => ""
            }
          ]
        },
        {
          :name => "User",
          :url  => 'new_app_user_url',
          :icon => "icon-plus-sign",
          :activities => [
            {
              :controller => "app_users",
              :action     => "new"
            } 
          ]
        },
        {
          :name => "Company",
          :url  => 'edit_main_company_url',
          :icon => "icon-home",
          :activities => [
            {
              :controller => "companies",
              :action     => "edit"
            } 
          ]
        }
      ]
      
    ] 
  }
  
  
  INVENTORY_NAV = {
    :header => "Inventory",
    :header_icon => "icon-copy",
    :has_dropdown => true, 
    :only_icon => false , 
    :blocks => [
      # block 1 
      [
        {
          :name => "Material",
          :url  => 'new_material_url',
          :icon => "icon-folder-open",
          :activities => [
            {
              :controller => "materials",
              :action     => "new"
            } 
          ]
        } 
      ]
      
    ] 
  }
  
  PAYMENT_NAV = {
    :header => "Payment",
    :header_icon => "icon-shopping-cart",
    :has_dropdown => true, 
    :only_icon => false , 
    :blocks => [
      # block 1 
      [
        {
          :name => "Invoice",
          :url  => 'new_invoice_url',
          :icon => "icon-folder-close",
          :activities => [
            {
              :controller => "invoices",
              :action     => "new"
            } 
          ]
        },
        {
          :name => "Pembayaran",
          :url  => 'new_payment_url',
          :icon => "icon-shopping-cart",
          :activities => [
            {
              :controller => "payments",
              :action     => "new"
            },
            {
              :controller => "invoice_payments",
              :action     => "new"
            }
          ]
        } 
      ]
      
    ] 
  }
  
  FACTORY_NAV = {
    :header => "Factory",
    :header_icon => "icon-shopping-cart",
    :has_dropdown => true, 
    :only_icon => false , 
    :blocks => [
      # block receive item 
      [
        {
          :name => "Penerimaan  Bubut",
          :url  => 'new_item_receival_url',
          :icon => "icon-folder-close",
          :activities => [
            {
              :controller => "item_receivals",
              :action     => "new"
            } 
          ]
        }
      ],
      
      
      # block production progress
      [
        {
          :name => "Pre Production",
          :url  => 'new_pre_production_history_url',
          :icon => "icon-folder-close",
          :activities => [
            {
              :controller => "pre_production_histories",
              :action     => "new"
            } 
          ]
        },
        {
          :name => "Production",
          :url  => 'new_production_history_url',
          :icon => "icon-shopping-cart",
          :activities => [
            {
              :controller => "production_histories",
              :action     => "new"
            } 
          ]
        },
        {
          :name => "Post Production",
          :url  => 'new_post_production_history_url',
          :icon => "icon-wrench",
          :activities => [
            {
              :controller => "post_production_histories",
              :action     => "new"
            } 
          ]
        } 
      ],
      
      # block sales return 
      [
        {
          :name => "Surat Jalan",
          :url  => 'new_delivery_url',
          :icon => "icon-wrench",
          :activities => [
            {
              :controller => "deliveries",
              :action     => "new"
            },
            {
              :controller => "delivery_entries",
              :action     => "new"
            }
          ]
        },
        {
          :name => "Sales Retur",
          :url  => 'new_sales_return_url',
          :icon => "icon-wrench",
          :activities => [
            {
              :controller => "sales_returns",
              :action     => "new"
            },
            {
              :controller => "sales_return_entries",
              :action     => "new"
            }
          ]
        },
        {
          :name => "Garansi  Retur",
          :url  => 'new_guarantee_return_url',
          :icon => "icon-wrench",
          :activities => [
            {
              :controller => "guarantee_returns",
              :action     => "new"
            },
            {
              :controller => "guarantee_return_entries",
              :action     => "new"
            }
          ]
        }
      ]
      
    ] 
  }
  
  SALES_NAV = {
    :header => "Sales",
    :header_icon => "icon-shopping-cart",
    :has_dropdown => true, 
    :only_icon => false , 
    :blocks => [
      # block 1 
      [
        {
          :name => "Customer",
          :url  => 'new_customer_url',
          :icon => "icon-folder-close",
          :activities => [
            {
              :controller => "customers",
              :action     => "new"
            } 
          ]
        } 
      ],
      
      # block sales return 
      [
        {
          :name => "Sales Order",
          :url  => 'new_sales_order_url',
          :icon => "icon-shopping-cart",
          :activities => [
            {
              :controller => "sales_orders",
              :action     => "new"
            },
            {
              :controller => "sales_items",
              :action     => "new"
            }
          ]
        } 
      ]
      
    ] 
  }
  
  def render_navigation( current_user , params ) 
    navigation_string = ""
    
    navigation_blocks = [] 
    [ 
      MANAGEMENT_NAV,
      INVENTORY_NAV,
      REPORT_NAV, 
      PAYMENT_NAV,
      FACTORY_NAV,
      SALES_NAV
    ].each do |nav|
      result  =  render_nav( current_user, params, nav)
      navigation_blocks << result if not result.nil?
    end
    
     # puts "********* the nav_blocks' length : #{navigation_blocks.length}\n"*5
    
    if navigation_blocks.length != 0 
      navigation_string << '<ul id="main-nav" class="nav pull-right">'
      navigation_string << navigation_blocks.join('')  
      # puts "The content: #{navigation_blocks.join('')  }"
      # puts "\n"
      navigation_string << '</ul>' 
    end
    
    # puts "the navigation_string: #{navigation_string}"
    return navigation_string 
  end
  
  
  # nav is the header 
  # nav has many nav blocks 
    # nav_blocks in one nav is separated by a divider 
  # nav block has_many nav elements
  def render_nav( current_user, params, nav ) 
    # nav blocks is array of blocks' navigation element (without the divider yet)
    nav_blocks = []
    nav_blocks_string = ""
    @is_nav_active = false 
    
    nav[:blocks].each do |nav_block|
      # nav block has_many nav elements 
      puts "the nav[:header] = #{nav[:header]}, gonna render nav block"
      result =  render_nav_block( current_user, params, nav_block) 
      nav_blocks << result if not  result.nil? and not result.length == 0
    end
    
    return nil if nav_blocks.length == 0 
  
    
    nav_blocks_count = nav_blocks.length 
    counter = 0
    
    nav_blocks.each do |nav_block|
      nav_blocks_string << nav_block
      if counter != nav_blocks_count  - 1 
        nav_blocks_string << draw_block_divider 
      end
      counter += 1 
    end
    
    
      # <li class="dropdown active">
    nav_blocks_string = draw_nav( nav_blocks_string, @is_nav_active , nav)
    
    return nav_blocks_string 
    
  end
  
  def draw_nav( nav_blocks_string, is_nav_active , nav )
    
    puts "\n"
    puts "The nav[:header] = #{nav[:header]}\n"
    puts "the is_nav_active value: #{is_nav_active}" 
    puts "\n\n"
    
		header_string = ""
		
		dropdown_string = "<ul class='dropdown-menu'>" + 
	                        nav_blocks_string         +
	                    "</ul>"
		nav_wrapper_string = "" 
		active = ACTIVE_CLASS if is_nav_active 
		if nav[:has_dropdown]
		  nav_wrapper_string = "<li class='dropdown #{active}'>"
		  
  		  header_string << "<a href='javascript:;' class='dropdown-toggle' data-toggle='dropdown'>"
  		  header_string << "<i class='#{nav[:header_icon]}'></i>"
  			header_string << '<span>'  + nav[:header]  + '</span>'
  			header_string << '<b class="caret"></b>'
  		  header_string << '</a>'
		  
		  
		  
	  else
	    nav_wrapper_string = "<li class='nav-icon #{active}'>"
  	    header_string = "<a>"
  	    header_string << '<i class="icon-home"></i>'
  	    header_string << '<span>'  + nav[:header]  + '</span>'
  	    header_string << '</a>' 
    end
		
		
		  nav_wrapper_string << header_string   
	    nav_wrapper_string << dropdown_string
	  nav_wrapper_string << "</li>"
		
		
	  return nav_wrapper_string
	
 
  end
  
  
  
  
  def render_nav_block( current_user, params, nav_block) 
    result_array  = [] 
    nav_block.each do |nav_element|
      if is_nav_element_visible?( current_user , nav_element) 
        is_active = false  
        is_active = true if is_nav_element_active?( params, nav_element )
        puts "The value of is_active: #{is_active}"
        if @is_nav_active == false  
          @is_nav_active = true  if is_active  
        end
        
        result_array << draw_nav_element( nav_element, is_active  )   
      end
    end
    
    
    
    return nil if result_array.length == 0  
    
    # puts "result_array.join('') : #{result_array.join('')}"
    return result_array.join('')
  end
  
  def is_nav_element_visible?( current_user , nav_element) 
    nav_element[:activities].each do |activity|
      return true if current_user.has_role?( activity[:controller], activity[:action])
    end
    
    return false 
  end
  
  def is_nav_element_active?( params, nav_element)
    nav_element[:activities].each do |activity|
      return true if params[:controller] == activity[:controller] && params[:action] == activity[:action]
    end
    
    return false
  end
  
  
  def draw_nav_element( nav_element, is_active ) 
    active_class = ''
    active_class = ACTIVE_CLASS if is_active 
    url = extract_url( nav_element[:url] )
    nav_element_string = ""
    nav_element_string << "<li class='#{active_class}'>"
    
    nav_element_string << "<a href='#{url}'>"
      nav_element_string << "<i class='#{nav_element[:icon]}'></i>#{nav_element[:name]}"
      nav_element_string << "</a>"
		nav_element_string << "</li>"
			  
    # puts("The nav_element_string: #{nav_element_string}")
		return nav_element_string 
  end
  
  def draw_block_divider
    return "<li class='divider'></li>"
  end
  
  
  
  def extract_url( some_url )
    if some_url == '#'
      return '#'
    end
    
    eval( some_url ) 
  end
  
end