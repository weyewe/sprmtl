class SalesItem < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :sales_order
  
  has_many :pre_production_orders
  has_many :production_orders
  has_many :post_production_orders
  
  has_many :pre_production_histories # PreProductionHistory 
  has_many :production_histories # ProductionHistory
  has_many :post_production_histories#  PostProductionHistory
  has_many :delivery_entries #  DeliveryEntry 
  has_many :sales_return_entries #  SalesReturnEntry
  has_many :delivery_lost_entries #  DeliveryLostEntry
  
  validates_presence_of :description
  validates_presence_of :creator_id
  validates_presence_of :price_per_piece
  # validates_presence_of :material_id 
  
  validate :material_must_present_if_production_is_true 
  validate :delivery_address_must_present_if_delivered_is_true 
  validate :quantity_must_be_at_least_one
  validate :price_per_piece_must_not_be_zero 
  
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
    new_object.quantity           = params[:quantity]          
    new_object.description        = params[:description]   
    new_object.delivery_address   = params[:delivery_address]          
    new_object.requested_deadline = params[:requested_deadline] # Date.new( 2013, 3,5 )
    new_object.price_per_piece    =  BigDecimal( params[:price_per_piece ])
    
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
  
  
=begin
  PRODUCTION PROGRESS TRACKING
=end
  def update_pending_production
    to_be_produced = self.production_orders.sum("quantity" )
    produced = self.production_histories.sum('quantity')
    
    self.pending_production = to_be_produced - produced 
    self.save 
  end
  
  def deduct_pending_production

=begin
  PRODUCTION PROGRESS STATISTIC
=end

  def update_pre_production_statistics 
    self.number_of_pre_production = self.pre_production_histories.sum('processed_quantity')
    self.save 
  end
  
  
  def update_production_statistics( production_history ) 
    
  end
   
  
=begin
  READY ITEM   ( Ready == pending delivery ) 
=end
  def update_ready_item 
    self.ready = self.total_finished - self.total_delivered
    self.save  
  end
   
  def total_finished 
    self.total_produced + self.total_repaired
  end
  
  def total_delivered
    self.delivery_entries.where(:is_confirmed => true).sum("quantity_sent")
  end
  
  def total_produced
    total_produced  = 0 
    if self.stop_at_production? 
      total_produced  = self.production_orders.sum("ok_quantity") 
    elsif self.stop_at_post_production?
      total_produced  = self.post_production_orders.sum("ok_quantity")
    end
    return total_produced 
  end
  
  def total_repaired
    self.production_repair_post_production_orders.sum("ok_quantity") + 
    self.sales_return_repair_post_production_orders.sum("ok_quantity")
  end
end
