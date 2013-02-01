class SalesItem < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :sales_order
  belongs_to :customer 
  belongs_to :template_sales_item 
  belongs_to :sales_item_subcription
  
  
  has_many :pre_production_orders
  has_many :production_orders
  has_many :post_production_orders
  
  has_many :delivery_entries
  
  has_many :pre_production_histories # PreProductionHistory 
  has_many :production_histories # ProductionHistory
  has_many :post_production_histories#  PostProductionHistory
  has_many :delivery_entries #  DeliveryEntry 
  has_many :sales_return_entries #  SalesReturnEntry
  has_many :delivery_lost_entries #  DeliveryLostEntry
  
  has_many :guarantee_return_entries
  has_many :item_receival_entries
  
  validates_presence_of :description
  validates_presence_of :name 
  validates_presence_of :creator_id
  # validates_presence_of :price_per_piece
  validates_presence_of :weight_per_piece
  validates_presence_of :quantity 
  validates_presence_of :case 
  
  validate :material_must_present_if_production_is_true 
  validate :delivery_address_must_present_if_delivered_is_true 
  validate :quantity_must_be_at_least_one
  validate  :weight_per_piece_must_not_be_less_than_zero
  
   
  
  def material_must_present_if_production_is_true
    if  is_production == true  and  material_id.nil?
      errors.add(:material_id , "Pilih Material karena ada produksi" )  
    end
  end
  
  def delivery_address_must_present_if_delivered_is_true
    if  is_delivered == true and  not delivery_address.present? 
      errors.add(:delivery_address , "Harus ada alamat pengiriman" )  
    end
  end
  
  def quantity_must_be_at_least_one
    if not quantity.present? or quantity <= 0 
      errors.add(:quantity , "Quantity harus setidaknya 1" )  
    end
  end
  
  
  def weight_per_piece_must_not_be_less_than_zero
    if  weight_per_piece <= BigDecimal('0')
      errors.add(:weight_per_piece , "Berat satuan tidak boleh kurang dari 0 kg" )  
    end
  end
  
  
  
  def delete(employee)
    return nil if employee.nil?
    return nil if self.is_confirmed? 
    
    self.destroy 
  end
  
  def SalesItem.create_sales_item( employee, sales_order, params ) 
    return nil if employee.nil?
    return nil if sales_order.nil? 
    
    new_object = SalesItem.new
    new_object.creator_id = employee.id 
    new_object.sales_order_id = sales_order.id 
    
    new_object.material_id           = params[:material_id]       
    new_object.is_pre_production     = params[:is_pre_production] 
    new_object.is_production       = params[:is_production]    
    # new_object.is_production         = true # by default  
    new_object.is_post_production    = params[:is_post_production]
    new_object.is_delivered          = params[:is_delivered]      
    new_object.delivery_address      = params[:delivery_address]  

    new_object.weight_per_piece      = BigDecimal( params[:weight_per_piece ])
    new_object.quantity              = params[:quantity]          
    new_object.description           = params[:description]   
    new_object.name                  = params[:name]
    
    new_object.customer_id = sales_order.customer_id 
    
    if params[:case].nil?
      new_object.case  = SALES_ITEM_CREATION_CASE[:new]
    end
    
    

    
    new_object.is_pending_pricing = params[:is_pending_pricing]
    if not new_object.is_pending_pricing
      new_object.pre_production_price  = BigDecimal( params[:pre_production_price]  )
      new_object.production_price      = BigDecimal( params[:production_price]      )
      new_object.post_production_price = BigDecimal( params[:post_production_price] )
      new_object.is_pricing_by_weight  =  params[:is_pricing_by_weight]  
    else 
      new_object.pre_production_price   = BigDecimal("0")
      new_object.production_price       = BigDecimal("0")
      new_object.post_production_price  = BigDecimal("0") 
    end                               
     

    new_object.requested_deadline    = params[:requested_deadline] # Date.new( 2013, 3,5 )

    
    
    if new_object.save 
      new_object.generate_code 
    end
    
    return new_object 
  end
  
  def update_sales_item( params ) 
    return nil if self.is_confirmed? 
    
    self.material_id           = params[:material_id]       
    self.is_pre_production     = params[:is_pre_production] 
    self.is_production       = params[:is_production]     
    # self.is_production         = true # by default 
    self.is_post_production    = params[:is_post_production]
    self.is_delivered          = params[:is_delivered]      
    self.delivery_address      = params[:delivery_address]  
    self.weight_per_piece      = BigDecimal( params[:weight_per_piece ])
    self.quantity              = params[:quantity]          
    self.description           = params[:description]   
    self.name                  = params[:name]
    
    self.is_pending_pricing = params[:is_pending_pricing]
    
    if not self.is_pending_pricing
      self.pre_production_price  = BigDecimal( params[:pre_production_price]  )
      self.production_price      = BigDecimal( params[:production_price]      )
      self.post_production_price = BigDecimal( params[:post_production_price] )
      self.is_pricing_by_weight  =  params[:is_pricing_by_weight]   
    else
      self.pre_production_price  = BigDecimal( '0' )
      self.production_price      = BigDecimal( '0' )
      self.post_production_price = BigDecimal( '0' )
    end
    
    
    self.requested_deadline    = params[:requested_deadline] 
    self.save 
    
    return self 
  end
  
=begin
##############################
##############################
##############################
  CREATING THE REPEAT_SALES_ITEM
##############################
##############################
##############################
=end
  def SalesItem.create_repeat_sales_item( employee, sales_order,  params )
    return nil if employee.nil?
    return nil if sales_order.nil? 
    return nil if params[:template_sales_item_id].nil? 
    
    new_object = SalesItem.new
    new_object.creator_id = employee.id 
    new_object.sales_order_id = sales_order.id 
    new_object.customer_id = sales_order.customer_id 
    
    template = TemplateSalesItem.find_by_id params[:template_sales_item_id]
    # related to the template sales item 
    sample_sales_item  = template.confirmed_sales_items.first 
    new_object.material_id           = sample_sales_item.material_id 
    new_object.weight_per_piece      = sample_sales_item.weight_per_piece 
    new_object.description           = sample_sales_item.description
    new_object.name                  = sample_sales_item.name
    
    
    # from params  
    new_object.quantity               = params[:quantity]  
    new_object.template_sales_item_id = params[:template_sales_item_id]
    new_object.is_pre_production      = params[:is_pre_production] 
    new_object.is_production          = params[:is_production]
    new_object.is_post_production     = params[:is_post_production]
    new_object.is_delivered           = params[:is_delivered]      
    new_object.delivery_address       = params[:delivery_address]  
    new_object.case                   = SALES_ITEM_CREATION_CASE[:repeat] 
    new_object.is_pending_pricing     = params[:is_pending_pricing]

    if not new_object.is_pending_pricing
      new_object.pre_production_price  = BigDecimal( params[:pre_production_price]  )
      new_object.production_price      = BigDecimal( params[:production_price]      )
      new_object.post_production_price = BigDecimal( params[:post_production_price] )
      new_object.is_pricing_by_weight  =  params[:is_pricing_by_weight]  
    else 
      new_object.pre_production_price   = BigDecimal("0")
      new_object.production_price       = BigDecimal("0")
      new_object.post_production_price  = BigDecimal("0") 
    end                               
     

    new_object.requested_deadline    = params[:requested_deadline] # Date.new( 2013, 3,5 )
    
    if sample_sales_item.is_production? and new_object.is_production == false 
      new_object.errors.add(:is_production , "Harus ada casting karena pesanan terdahulu memiliki casting" )  
      return new_object 
    end
 
    
    if new_object.save 
      new_object.code = template.code 
      new_object.save 
    end
    
    return new_object
  end
  
  
  def update_repeat_sales_item( params ) 
    return nil if self.is_confirmed? 
    template = TemplateSalesItem.find_by_id params[:template_sales_item_id]
    
    if self.template_sales_item_id != template.id
      # change the template and the data related to it 
      sample_sales_item  = template.confirmed_sales_items.first 
      self.material_id           = sample_sales_item.material_id 
      self.weight_per_piece      = sample_sales_item.weight_per_piece 
      self.description           = sample_sales_item.description
      self.name                  = sample_sales_item.name
      self.template_sales_item_id = template.id 
    end
    
    self.quantity              = params[:quantity]
    
    self.is_pre_production     = params[:is_pre_production] 
    self.is_production       = params[:is_production]     
    self.is_post_production    = params[:is_post_production]
    self.is_delivered          = params[:is_delivered]      
    self.delivery_address      = params[:delivery_address]   
    self.is_pending_pricing = params[:is_pending_pricing]
    
    if not self.is_pending_pricing
      self.pre_production_price  = BigDecimal( params[:pre_production_price]  )
      self.production_price      = BigDecimal( params[:production_price]      )
      self.post_production_price = BigDecimal( params[:post_production_price] )
      self.is_pricing_by_weight  =  params[:is_pricing_by_weight]   
    else
      self.pre_production_price  = BigDecimal( '0' )
      self.production_price      = BigDecimal( '0' )
      self.post_production_price = BigDecimal( '0' )
    end
    
    
    self.requested_deadline    = params[:requested_deadline] 
    self.save 
    
    return self
  end
  
=begin
##############################
##############################
##############################
  END OF REPEAT_SALES_ITEM
##############################
##############################
##############################
=end
  
  def generate_code
    
    start_datetime = Date.today.at_beginning_of_month.to_datetime
    end_datetime = Date.today.next_month.at_beginning_of_month.to_datetime
    
    counter = self.class.where{
      (self.created_at >= start_datetime)  & 
      (self.created_at < end_datetime )
    }.count
    
    if self.is_confirmed?
      counter = self.class.where{
        (self.created_at >= start_datetime)  & 
        (self.created_at < end_datetime ) & 
        (self.is_confirmed.eq true )
      }.count
    end
    
    header = ""
    if not self.is_confirmed?  
      header = "[pending]"
    end
    
    
    
    # Misalnya ada order FCD pada tanggal 21 januari 2013 dengan nomor urut 2 berarti nulisnya 
    # B13-0102 (Kode material Tahun order - Bulan order Nomor urut)
    # 
    material_code = "" 
    if not self.only_post_production? and not self.material_id.nil?
      material_code = Material.find_by_id( self.material_id ) .code 
    elsif self.only_post_production?
      material_code = "N"
    end
    
    string = "#{header}#{material_code}" + 
              ( self.created_at.year%1000).to_s + "-" + 
              ( self.created_at.month).to_s + '-' + 
              ( counter.to_s ) 
              
    # string = "#{header}SI" + "/" + 
    #           self.created_at.year.to_s + '/' + 
    #           self.created_at.month.to_s+ '/' + 
    #           counter .to_s
    #           
    self.code =  string 
    self.save 
  end
  
  def generate_template_sales_item
    if self.case == SALES_ITEM_CREATION_CASE[:new]
      template_si = TemplateSalesItem.create_based_on_sales_item( self )
      self.template_sales_item_id = template_si.id 
      self.save 
    end
  end
  
  def generate_customer_subcription
    return nil if not self.sales_item_subcription.nil? 
    
    si_subcription = nil 
    
      si_subcription = SalesItemSubcription.create_or_find_subcription(self)  
   
    
    self.sales_item_subcription_id = si_subcription.id 
    self.save
    
    
    
  end
  
  
  
  
  def confirm
    return nil if self.is_confirmed == true 
    
    self.is_confirmed = true 
    self.save
    
    if self.case == SALES_ITEM_CREATION_CASE[:new]
      self.generate_code
      self.generate_template_sales_item 
    end
    
    self.generate_customer_subcription
    self.reload 
    if self.only_machining?
       
    elsif self.casting_included?
      production_order = ProductionOrder.create_sales_production_order( self )
      self.update_on_confirm 
    end    
    
  end
  
  
  
  def only_machining?
    self.is_production == false && self.is_post_production == true 
  end
  
  def only_post_production?
    only_machining? 
  end
  
  def casting_included? 
    self.is_production == true 
  end
  
  def has_post_production?
    self.is_post_production?
  end
  
  def only_production?
    stop_at_production?
  end
  
  def stop_at_production?
    self.is_post_production == false and self.is_production == true 
  end
  
  def stop_at_post_production?
    self.is_post_production == true 
  end
  
  def has_unconfirmed_pre_production_history?
    self.pre_production_histories.where(:is_confirmed => false ).count != 0 
  end
  
  
  
##############################################################
###############################
############ PRODUCTION 
###############################
##############################################################
  
=begin
  PRODUCTION PROGRESS TRACKING
=end
  
  def sales_production_orders
    if self.only_machining?
      return [] 
    elsif casting_included? 
      return self.production_orders.where(:case    => PRODUCTION_ORDER[:sales_order]) 
    end
  end
  
  def production_failure_production_orders
    self.production_orders.where(:case => PRODUCTION_ORDER[:production_failure])
  end
  
  def has_unconfirmed_production_history?
    self.production_histories.where(:is_confirmed => false ).count != 0 
  end

  def adjustment_to_production_order
    self.number_of_failed_production   +   
                                  self.number_of_failed_post_production    +
                                  self.number_of_delivery_lost + 
                                  self.sales_return_entries.where(:is_confirmed => true ).sum("quantity_for_production")
  end

  
  

=begin
  PRODUCTION PROGRESS STATISTIC
=end

  def update_pre_production_statistics 
    self.number_of_pre_production = self.pre_production_histories.where(:is_confirmed => true ).sum('processed_quantity')
    self.save 
  end
   
=begin
  INTERFACING 
                PRODUCTION  => READY 
                          AND 
          POST PRODUCTION  => READY
=end

  def generate_next_phase_after_production( production_history )
    if self.has_post_production? # stop at post_production 
      # if it has post production, the repairable will be counted as post production work 
      # repairable + ok 
      PostProductionOrder.generate_sales_post_production_order( production_history ) 
      
    else  # stop at production 
      # if it doesn't have post production, the repairing work will be internal extra expense 
      PostProductionOrder.generate_production_repair_post_production_order( production_history ) 
    end 
    
    ProductionOrder.generate_production_failure_production_order( production_history )
    # don't need to generate production failure production order
    # example: asked to make 50. we make 1.. fail.. pending production will still be 50
    #  no extra production order needed
    
  end
  
  
  def production_finished_quantity
    if self.stop_at_production? 
      return self.production_histories.sum("ok_quantity")  
    else self.stop_at_post_production? 
      return self.production_histories.sum("ok_quantity")  + 
              self.production_histories.sum("repairable_quantity")
    end
  end
  
  
=begin
  There are 3 types of production:
  1. production => post production (by request) => ready 
  2. production => post production (repair broken production) => ready 
  3. production => ready ( no need to repair, and not asked to do post production @ sales item)
=end

  
  
  def update_production_statistics 
  
    #  
    
         
    # :pending_post_production  
    
    # self.pending_post_production = self.post_production_orders.sum("quantity") -  
    #                               self.post_production_histories.sum("ok_quantity")
    
    # :ready                    
     # ready == pending delivery
    
    
    # number_of_production
    self.update_number_of_production
    # self.number_of_production = self.production_histories.sum("processed_quantity")
    
    # number_of_failed_production
    self.update_number_of_failed_production
    # self.number_of_failed_production = self.production_histories.sum("broken_quantity")
    
    
     # :pending_production 
    self.update_pending_production 
    self.update_pending_post_production 
    self.update_ready_statistics 
    
    self.save  
  end
  
##############################################################
###############################
############ POST PRODUCTION 
###############################
##############################################################


=begin
   POST PRODUCTION PROGRESS TRACKING
=end

  def sales_post_production_orders
    self.post_production_orders.where(:case => POST_PRODUCTION_ORDER[:sales_order] )
  end
   
  def has_unconfirmed_post_production_history?
    self.post_production_histories.where(:is_confirmed => false ).count != 0 
  end
 
  def post_production_failure_production_orders
    self.production_orders.where(:case => PRODUCTION_ORDER[:post_production_failure])
  end
  
  
 
=begin
  POST PRODUCTION INTERFACE with delivery
=end

  # over here, we are assuming that all sales item come with production 
  def generate_next_phase_after_post_production( post_production_history )
    
    # all things going from post production is the ready item 
    
    
    # puts "Total number of broken quantity: #{post_production_history.broken_quantity}\n"*10
    # for the failure 
    if self.is_production? and post_production_history.quantity_to_be_reproduced != 0 
      ProductionOrder.generate_post_production_failure_production_order( post_production_history  ) 
    else
      # if no production, just post production.. don't do anything.. do it as it is 
      # => REturn the bad source and broken to customer.. reimburse or whatever
      # => the policy is to be announced 
    end 
    
  end
  
  def sales_return_pending_production_replacement_quota 
    quota_for_post_production_failure_replacement -  
      used_quota_for_post_production_failure_replacement
  end
  
  def quota_for_post_production_failure_replacement
    self.sales_return_entries.
      where(:is_confirmed => true).
      sum("quantity_for_post_production")
  end
  
  def used_quota_for_post_production_failure_replacement
    self.production_orders.
      where(:case =>  PRODUCTION_ORDER[:sales_return_post_production_failure]).
      sum("quantity")
  end
  
  
  def post_production_finished_quantity
    return self.post_production_histories.where(:is_confirmed => true ).sum("ok_quantity")
  end
  
  def post_production_fail_quantity
    return self.post_production_histories.where(:is_confirmed => true ).sum("broken_quantity") + 
          self.post_production_histories.where(:is_confirmed => true ).sum("bad_source_quantity")
  end
  
  def update_number_of_post_production
    self.number_of_post_production = self.post_production_histories.where(:is_confirmed => true).sum("processed_quantity")
    self.save
  end
  
  def update_number_of_failed_post_production
    self.number_of_failed_post_production = self.post_production_histories.sum("broken_quantity")
    self.save
  end
  
  def update_post_production_statistics 
    # :pending_production  
    
    # self.pending_post_production = self.post_production_orders.sum("quantity") - 
    #                           self.post_production_finished_quantity
    self.update_pending_post_production 
     
    # :ready                    
    self.update_ready_statistics 
    
    # number_of_production
    
    self.update_number_of_post_production
    
    
    # number_of_failed_production
    self.update_number_of_failed_post_production
    
    self.save  
  end

  
   
 
 
 
##############################################################
###############################
############ DELIVERY 
###############################
############################################################## 
=begin
  READY ITEM   ( Ready == pending delivery ) 
=end
  def update_ready_statistics
    self.ready = self.total_finished - self.total_delivered
    self.save  
  end
   
  def total_finished 
    total  = 0 
    if self.stop_at_production? 
      total  = self.production_histories.sum("ok_quantity")  +   # original production work 
                self.post_production_histories.sum("ok_quantity")  # repair work 
    elsif self.stop_at_post_production?
      total  = self.post_production_histories.sum("ok_quantity") # all post production work 
    end
    
    return total
  end
  
  # all the items going out 
  def total_delivered
    self.delivery_entries.where(:is_confirmed => true).sum("quantity_sent")
  end
  
 
=begin
  ON sending out the goods 
  # OMAKASE STYLE!! ahahaha ^_^
=end
  
  def update_delivery_lost
    all_confirmed_entries = self.delivery_entries .where( :is_confirmed => true ) 
    all_finalized_entries = all_confirmed_entries.where(:is_finalized => true)
    total_items_lost      = all_finalized_entries.sum('quantity_lost')
    self.number_of_delivery_lost = total_items_lost
    self.save 
  end
  
  
# not updating delivery_lost 
  def update_on_delivery_statistics
    # we will update on_delivery.. number of items on the way to the customer's site 
    
    # when it is confirmed, it is deducting the stock 
    all_confirmed_entries = self.delivery_entries .where( :is_confirmed => true ) 
    
    # when it is finalized, it is the approval from the customer 
    all_finalized_entries = all_confirmed_entries.where(:is_finalized => true)
    
    total_items_going_out = all_confirmed_entries.sum("quantity_sent")
    total_items_approved  = all_finalized_entries.sum("quantity_confirmed")
    total_items_returned  = all_finalized_entries.sum("quantity_returned")
    total_items_lost      = all_finalized_entries.sum('quantity_lost')

    
    # puts "\n"
    # puts "size of confirmed entries: #{all_confirmed_entries.length}"
    # puts "size of finalized entries: #{all_finalized_entries.length}"
    # puts "!!!!!!!!!!!!!!!!!!!!!!!! UPDATE on DELIVERY STATISTICS\n"*2
    # puts "total_items_going_out: #{total_items_going_out}"
    # puts "total_items_approved (confirmed): #{total_items_approved}"
    # puts "total_items_returned: #{total_items_returned}"
    # puts "total_items_lost: #{total_items_lost}"
    
    self.on_delivery = total_items_going_out  - 
                        total_items_approved  -
                        total_items_returned  -   # can it be returned at later date? => no idea
                        total_items_lost
                        
    # puts ">>>>>>>> latest on_delivery: #{ self.on_delivery}"
    self.save 
  end

=begin
  on DELIVERY FINALIZATION =>  CUSTOMER approves the number of delivery item, 
                            sales return and , delivery lost 
=end

  def update_post_delivery_statistics
    # sales return and delivery lost will be created on their own class
    # with logic to trigger the ProductionOrder => for lost delivery
    # for sales return, there are 2 possibility => PostProductionOrder or ProductionOrder. 
    
    self.fulfilled_order = self.delivery_entries.where(
                            :is_confirmed => true, 
                            :is_finalized => true 
                          ).sum("quantity_confirmed")
    
    self.save 
  end

  
  
  
  # def total_repaired
  #   self.production_repair_post_production_orders.sum("ok_quantity") + 
  #   self.sales_return_repair_post_production_orders.sum("ok_quantity")
  # end
  
=begin  
  UPDATER UTILITY
=end
# things that must have been updated: 
# => number_of_failed_production
# => number_of_failed_post_production
# => number_of_delivery_lost

###################################################
#
# => What is Pending Production? Number of quantity that I need to cast 
#
#
####################################################
  def update_pending_production 
    
    produced_quantity  =   self.production_finished_quantity 
    
    adjustment_to_production_order  = self.number_of_failed_production   
    
    self.pending_production =  self.production_orders.sum("quantity") -    
                                produced_quantity - 
                                adjustment_to_production_order 
    self.save 
  end
  
  def update_number_of_production
    self.number_of_production = self.production_histories.sum("processed_quantity")
    self.save
  end
  
  def update_number_of_failed_production
    self.number_of_failed_production = self.production_histories.sum("broken_quantity")
    self.save
  end
  
  def update_pending_post_production  
    produced = self.post_production_finished_quantity    + self.post_production_fail_quantity 
    
    # no such thing as adjustment.. on sales return.. it will be decided whether
      # it will have post production as fix or production => ProductionOrder || PostProductionOrder
    # post_production_order_adjustment =    self.sales_return_entries.where(:is_confirmed => true ).
    #                                     sum("quantity_for_post_production")
    
                           
    self.pending_post_production = self.post_production_orders.sum("quantity")  - 
                                      produced   
    self.save
  end
  
  def update_ready
    self.ready = self.total_finished - self.total_delivered
    self.save
  end
  
  def update_on_delivery
    all_confirmed_entries = self.delivery_entries .where( :is_confirmed => true ) 
    
    # when it is finalized, it is the approval from the customer 
    all_finalized_entries = all_confirmed_entries.where(:is_finalized => true)
    
    total_items_going_out = all_confirmed_entries.sum("quantity_sent")
    total_items_approved  = all_finalized_entries.sum("quantity_confirmed")
    total_items_returned  = all_finalized_entries.sum("quantity_returned")
    total_items_lost      = all_finalized_entries.sum('quantity_lost') 
    
    self.on_delivery = total_items_going_out  - 
                        total_items_approved  -
                        total_items_returned  -   # can it be returned at later date? => no idea
                        total_items_lost
                        
    self.save
  end
  
  def update_number_of_delivery
    self.number_of_delivery = self.delivery_entries.where(:is_confirmed => true).sum("quantity_sent")
  end
  
  def update_fulfilled_order
    # self.fulfilled_order = self.delivery_entries.where(
    #                         :is_confirmed => true, 
    #                         :is_finalized => true 
    #                       ).sum("quantity_confirmed")
    # 
   
    self.fulfilled_order = self.delivery_entries.where{
      (is_confirmed.eq true ) & 
      (is_finalized.eq true) & 
      (entry_case.not_eq DELIVERY_ENTRY_CASE[:guarantee_return] )
    }.sum("quantity_confirmed")
    
     
    self.save
  end
  
  
  def update_number_of_delivery_lost
    all_confirmed_entries = self.delivery_entries .where( :is_confirmed => true ) 
    all_finalized_entries = all_confirmed_entries.where(:is_finalized => true)
    total_items_lost      = all_finalized_entries.sum('quantity_lost')
    self.number_of_delivery_lost = total_items_lost
    self.save 
  end
  
  def update_number_of_sales_return
    # confirmed_sales_return_entries = self.sales_return_entries.where(:is_confirmed => true )
    self.number_of_sales_return = self.delivery_entries.
                            where(:is_confirmed =>true, :is_finalized => true ).
                            sum("quantity_returned")
    self.save
  end
  
  
=begin  
  UPDATER MAIN function
=end

  def update_on_confirm
    #pending_production
    update_pending_production
  end
  
  def update_on_production_history_confirm
    update_number_of_production
    update_number_of_failed_production
    update_pending_production
    update_pending_post_production 
    update_ready 
  end
  
##########################################
########## START OF ONLY_POST_PRODUCTION 
##########################################
=begin
  SPECIAL CASE: ONLY POST PRODUCTION
=end
  def update_on_item_receival_confirm 
    # create PostProductionOrder
    
    
    # update pending post production
    update_pending_post_production
  end
  
##########################################
########## END OF ONLY_POST_PRODUCTION 
##########################################
  
  def update_on_post_production_history_confirm
    
    if not self.only_post_production? 
      update_number_of_post_production
      update_number_of_failed_post_production 
      update_pending_production
      update_pending_post_production
      update_ready 
    else
      update_number_of_post_production
      update_pending_post_production
      update_number_of_failed_post_production  # sum of bad item and company failure 
      update_ready
    end
  end
  
  
  
  def update_on_delivery_confirm
    update_on_delivery
    update_number_of_delivery
    update_number_of_sales_return
    update_ready
  end
  
  def update_on_delivery_item_finalize
    update_on_delivery
    update_fulfilled_order
    update_number_of_sales_return
  end
  
  def update_on_guarantee_return_delivery_item_finalize
    update_on_delivery
    update_guarantee_return_statistic
  end
  
  def update_guarantee_return_statistic
    # update number_of_guarantee_return 
    number_of_guarantee_return_count = self.guarantee_return_entries.
                        where(:is_confirmed => true).sum("quantity_for_post_production")
    number_of_guarantee_return_count += self.guarantee_return_entries.
                        where(:is_confirmed => true).sum("quantity_for_production")
    self.number_of_guarantee_return  = number_of_guarantee_return_count
                        
                        
    # update pending_guarantee_return_delivery 
    # total production order involving guarantee_return - total guarantee_return delivery 
    guarantee_return_delivery_count = self.delivery_entries.where(:is_finalized => true,
      :entry_case => DELIVERY_ENTRY_CASE[:guarantee_return ]
    ).sum("quantity_confirmed")
    self.pending_guarantee_return_delivery = number_of_guarantee_return_count -  guarantee_return_delivery_count 
    self.save
    
    # policy: what if you do sales return on delivery_entry with guarantee_return? 
    # take it as confirmed. create a new guarantee_return
  end
  
  def update_on_delivery_lost_entry_confirm
    update_number_of_delivery_lost
    update_pending_production #for delivery lost
  end
  
  def update_on_sales_return_confirm
    update_number_of_sales_return
    update_pending_production
    update_pending_post_production
  end
  
  
  
  def update_on_guarantee_return_confirm
    update_pending_production
    update_pending_post_production 
    
    
    # update number_of_guarantee_return 
    number_of_guarantee_return_count = self.guarantee_return_entries.
                        where(:is_confirmed => true).sum("quantity_for_post_production")
    number_of_guarantee_return_count += self.guarantee_return_entries.
                        where(:is_confirmed => true).sum("quantity_for_production")
    self.number_of_guarantee_return  = number_of_guarantee_return_count
                        
                        
    # update pending_guarantee_return_delivery 
    # total production order involving guarantee_return - total guarantee_return delivery 
    guarantee_return_delivery_count = self.delivery_entries.where(:is_finalized => true,
      :entry_case => DELIVERY_ENTRY_CASE[:guarantee_return ]
    ).sum("quantity_confirmed")
    self.pending_guarantee_return_delivery = number_of_guarantee_return_count -  guarantee_return_delivery_count 
    self.save
    
    # policy: what if you do sales return on delivery_entry with guarantee_return? 
    # take it as confirmed. create a new guarantee_return 
  end
  
end
