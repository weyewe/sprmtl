class ProductionHistory < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :sales_item 
  validates_presence_of  :processed_quantity, 
                          :ok_quantity,  :broken_quantity,  #:repairable_quantity,
                          :ok_weight,   :broken_weight,  #:repairable_weight,
                          :start_date, :finish_date
                          
  validates_numericality_of :ok_quantity, :broken_quantity  ,  #:repairable_quantity, 
                          :ok_weight, :broken_weight  #:repairable_weight,
                  
   
  
  def ProductionHistory.create_history( employee, sales_item , param ) 
    return nil if employee.nil?  or sales_item.nil? 
    
    new_object  = ProductionHistory.new
    
    
    new_object.ok_quantity         = params[:ok_quantity]
    # new_object.repairable_quantity = params[:repairable_quantity]
    new_object.broken_quantity     = params[:broken_quantity] 
    new_object.ok_weight           = params[:ok_weight] 
    # new_object.repairable_weight   = params[:repairable_weight] 
    new_object.broken_weight       = params[:broken_weight] 
    new_object.start_date          = params[:start_date] 
    new_object.finish_date         = params[:finish_date] 

    
    if new_object.save   
      new_object.update_processed_quantity
      sales_item.update_production_statistics( new_object )  
      
      #  result in production => ok or broken 
      # broken in postproduction => ok or broken  --> that's it.. no repair  (cross department will confuse them)
      if sales_item.is_post_production? 
        # generate PostProductionOrder 
        PostProductionOrder.generate_sales_production_order( new_object )
      else
        # update item ready
        sales_item.update_ready_item( new_object )  
      end
      
 
    end
    
    return new_object 
  end
  
  def update_processed_quantity 
    self.processed_quantity = new_object.ok_quantity  + 
                                    # new_object.repairable_quantity + 
                                    new_object.broken_quantity
    self.save
  end
  
  def is_a_number?(s)
    s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true 
  end
end
