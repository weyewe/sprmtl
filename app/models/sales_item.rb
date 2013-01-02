class SalesItem < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :sales_order
  
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
  
  validates_presence_of :description
  validates_presence_of :creator_id
  validates_presence_of :price_per_piece
  validates_presence_of :weight_per_piece
  validates_presence_of :quantity 
  
  validate :material_must_present_if_production_is_true 
  validate :delivery_address_must_present_if_delivered_is_true 
  validate :quantity_must_be_at_least_one
  validate :price_per_piece_must_not_be_zero 
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
  
  def price_per_piece_must_not_be_zero
    if  price_per_piece <= BigDecimal('0')
      errors.add(:price_per_piece , "Harga jual satuan harus lebih dari 0" )  
    end
  end
  
  def weight_per_piece_must_not_be_less_than_zero
    if  weight_per_piece <= BigDecimal('0')
      errors.add(:weight_per_piece , "Berat satuan tidak boleh kurang dari 0 kg" )  
    end
  end
  
  def SalesItem.create_sales_item( employee, sales_order, params ) 
    return nil if employee.nil?
    return nil if sales_order.nil? 
    
    new_object = SalesItem.new
    new_object.creator_id = employee.id 
    new_object.sales_order_id = sales_order.id 
    
    new_object.material_id        = params[:material_id]       
    new_object.is_pre_production  = params[:is_pre_production] 
    new_object.is_production      = params[:is_production]     
    new_object.is_post_production = params[:is_post_production]
    new_object.is_delivered       = params[:is_delivered]      
    new_object.delivery_address   = params[:delivery_address]  
    new_object.price_per_piece    =  BigDecimal( params[:price_per_piece ])
    new_object.weight_per_piece    =  BigDecimal( params[:weight_per_piece ])
    new_object.quantity           = params[:quantity]          
    new_object.description        = params[:description]   
    new_object.delivery_address   = params[:delivery_address]          
    new_object.requested_deadline = params[:requested_deadline] # Date.new( 2013, 3,5 )
    
    
    if new_object.save 
      new_object.generate_code 
    end
    
    return new_object 
  end
  
  
  def generate_code
    string = "SI" + "/" + 
              self.created_at.year.to_s + '/' + 
              self.created_at.month.to_s+ '/' + 
              self.id .to_s
              
    self.code =  string 
    self.save 
  end
  
  def confirm
    return nil if self.is_confirmed == true 
    
    if self.only_machining?
      PostProductionOrder.create_machining_only_sales_production_order( self )
    elsif self.casting_included?
      production_order = ProductionOrder.create_sales_production_order( self )
      self.update_pending_production 
    end    
    
    self.is_confirmed = true 
    self.save 
  end
  
  def only_machining?
    self.is_production == false && self.is_post_production == true 
  end
  
  def casting_included? 
    self.is_production == true 
  end
  
  def has_post_production?
    self.is_post_production?
  end
  
  def stop_at_production?
    self.is_post_production == false and self.is_production == true 
  end
  
  def stop_at_post_production?
    self.is_post_production == true 
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

  def update_pending_production
    to_be_produced = self.production_orders.sum("quantity" )
    produced = self.production_histories.where(:is_confirmed => true ) . sum('ok_quantity')  + 
                    self.production_histories.where(:is_confirmed => true ) . sum('repairable_quantity')  
    
    self.pending_production = to_be_produced - produced 
    self.save 
  end
  

=begin
  PRODUCTION PROGRESS STATISTIC
=end

  def update_pre_production_statistics 
    self.number_of_pre_production = self.pre_production_histories.sum('processed_quantity')
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
  
    # :pending_production   
    self.pending_production = self.production_orders.sum("quantity") - 
                              self.production_finished_quantity
         
    # :pending_post_production  
    self.pending_post_production = self.post_production_orders.sum("quantity") -  
                                  self.post_production_histories.sum("ok_quantity")
    
    # :ready                    
    self.update_ready_statistics  # ready == pending delivery
    
    
    # number_of_production
    self.number_of_production = self.production_histories.sum("processed_quantity")
    
    # number_of_failed_production
    self.number_of_failed_production = self.production_histories.sum("broken_quantity")
    
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
  
  def update_pending_post_production
    to_be_produced = self.post_production_orders.sum("quantity" )
    produced = self.post_production_histories.sum('ok_quantity')
    
    # puts "IN THE SALES ITEM: to_be_produced: #{to_be_produced}"
    # puts "IN THE SALES ITEM: produced: #{produced}"
    
    self.pending_post_production = to_be_produced - produced 
    # puts "IN THE SALES ITEM: pending_production: #{pending_production}"
    
    self.save 
  end
 
=begin
  POST PRODUCTION INTERFACE with delivery
=end

  # over here, we are assuming that all sales item come with production 
  def generate_next_phase_after_post_production( post_production_history )
    
    # all things going from post production is the ready item 
    
    # for the failure 
    if self.is_production?
      ProductionOrder.generate_post_production_failure_production_order( post_production_history ) 
      self.update_production_statistics
    else
      # FUCK>> ASK the company for the policy
      
      # reimburse? or, there is no case of this at all?
    end 
  end
  
  
  def post_production_finished_quantity
    return self.post_production_histories.sum("ok_quantity")
  end
  
  def update_post_production_statistics(post_production_history)
    # :pending_production  
    
    self.pending_post_production = self.post_production_orders.sum("quantity") - 
                              self.post_production_finished_quantity
     
    # :ready                    
    self.update_ready_statistics 
    
    # number_of_production
    self.number_of_post_production = self.post_production_histories.sum("processed_quantity")
    
    # number_of_failed_production
    self.number_of_failed_post_production = self.post_production_histories.sum("broken_quantity")
    
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
end
