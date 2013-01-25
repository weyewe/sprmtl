class ItemReceivalEntry < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :item_receival
  belongs_to :sales_item 
  
  validates_presence_of :quantity
  
  validate :quantity_is_not_zero
  
  def quantity_is_not_zero
    if  quantity.present? and quantity <= 0 
      errors.add(:quantity , "Kuantitas harus lebih dari 0 " )  
    end
  end

  def self.create_item_receival_entry( employee, item_receival,  params ) 
    return nil if employee.nil?
    
    new_object = self.new
    new_object.creator_id       = employee.id 
    new_object.item_receival_id = item_receival.id 
    new_object.sales_item_id    = params[:sales_item_id] 
    new_object.quantity         = params[:quantity]      
 
    
    if new_object.save 
      new_object.generate_code 
    end
    
    return new_object 
  end
  
  def update_item_receival_entry( employee, item_receival,  params ) 
    return nil if employee.nil?
    
   
    self.creator_id        = employee.id 
    self.item_receival_id = item_receival.id 
    self.sales_item_id    = params[:sales_item_id] 
    self.quantity         = params[:quantity]    
    if self.save 
    end
    
    return self 
  end
  
  def delete( employee )
    return nil if employee.nil?
    return nil if self.is_confirmed? 
    
    self.destroy 
  end
  
  def confirm 
    return nil if self.is_confirmed == true  
    self.is_confirmed = true 
    
    self.save 
    
    self.generate_code
    
     
    if  self.errors.size != 0  
      raise ActiveRecord::Rollback, "Call tech support!" 
    end
    
    PostProductionOrder.generate_item_receival_post_production_order( self )
    
    sales_item = self.sales_item 
    sales_item.update_on_item_receival_confirm  # update pending post production? 
  end
  
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
    
    string = "#{header}IRE" + "/" + 
              self.created_at.year.to_s + '/' + 
              self.created_at.month.to_s+ '/' + 
              counter.to_s
              
    self.code =  string 
    self.save 
  end
end
