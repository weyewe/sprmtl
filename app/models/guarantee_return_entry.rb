class GuaranteeReturnEntry < ActiveRecord::Base
  belongs_to :guarantee_return 
  belongs_to :sales_item 

  def self.create_guarantee_return_entry( employee, guarantee_return,  params ) 
    return nil if employee.nil?
    
    new_object = self.new
    new_object.creator_id       = employee.id 
    new_object.guarantee_return_id          = guarantee_return.id 
    new_object.sales_item_id                = params[:sales_item_id] 
    new_object.quantity_for_post_production = params[:quantity_for_post_production]      
    new_object.quantity_for_production      = params[:quantity_for_production]
    new_object.weight_for_post_production   = BigDecimal( params[:weight_for_post_production] )     
    new_object.weight_for_production        = BigDecimal( params[:weight_for_production] ) 

    
    if new_object.save 
      new_object.generate_code 
    end
    
    return new_object 
  end
  
  def update_guarantee_return_entry( employee, guarantee_return,  params ) 
    return nil if employee.nil?
    
   
    self.creator_id        = employee.id 
    self.guarantee_return_id = guarantee_return.id 
    self.sales_item_id                = params[:sales_item_id] 
    self.quantity_for_post_production = params[:quantity_for_post_production]      
    self.quantity_for_production      = params[:quantity_for_production]
    self.weight_for_post_production   = BigDecimal( params[:weight_for_post_production] )     
    self.weight_for_production        = BigDecimal( params[:weight_for_production] )
     
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
    
    ProductionOrder.generate_guarantee_return_production_order( self  )
    PostProductionOrder.generate_guarantee_return_post_production_order( self )
    
    # PostProductionOrder generaet guarantee return order  
    # Production order generate guarantee return order 
    # sales_item = self.sales_item 
    sales_item.update_on_guarantee_return_confirm 
    
    
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
    
    string = "#{header}GRE" + "/" + 
              self.created_at.year.to_s + '/' + 
              self.created_at.month.to_s+ '/' + 
              counter.to_s
              
    self.code =  string 
    self.save 
  end
end
