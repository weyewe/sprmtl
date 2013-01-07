@sales_order.confirm(@admin)
@complete_cycle_sales_item.reload

@processed_quantity = 20
@ok_quantity = 18 
@broken_quantity = 1
@repairable_quantity = 1 

@production_history = ProductionHistory.create_history( @admin, @complete_cycle_sales_item, {
  :processed_quantity    => @processed_quantity, 
  :ok_quantity           => @ok_quantity, 
  :repairable_quantity   => @repairable_quantity, 
  :broken_quantity       => @broken_quantity, 

  :ok_weight             =>  "#{8*15}" ,  # in kg.. .00 
  :repairable_weight     => '13',
  :broken_weight         =>  "#{2*10}" ,

  # :person_in_charge      => nil ,# list of employee id 
  :start_date            => Date.new( 2012, 10,10 ) ,
  :finish_date           => Date.new( 2013, 1, 15) 
})

@initial_pending_production = @complete_cycle_sales_item.pending_production
@initial_pending_post_production = @complete_cycle_sales_item.pending_post_production 

@production_history.confirm(@admin)
@complete_cycle_sales_item.reload
@pending_post_production = @complete_cycle_sales_item.pending_post_production

@total_post_production_1 = 15

@post_production_broken_1 = 1 
@post_production_ok_1 = @total_post_production_1 - @post_production_broken_1
@post_production_history = PostProductionHistory.create_history( @admin, @complete_cycle_sales_item, {
  :ok_quantity           => @post_production_ok_1, 
  :broken_quantity       => @post_production_broken_1, 

  :ok_weight             =>  "#{@post_production_ok_1*15}" ,  # in kg.. .00 
  :broken_weight         =>  "#{@post_production_broken_1*10}" ,

  # :person_in_charge      => nil ,# list of employee id 
  :start_date            => Date.new( 2012, 10,10 ) ,
  :finish_date           => Date.new( 2013, 1, 15) 
})

@complete_cycle_sales_item.reload 

@initial_pending_post_production = @complete_cycle_sales_item.pending_post_production 
@initial_ready      = @complete_cycle_sales_item.ready
@initial_pending_production  =  @complete_cycle_sales_item.pending_production 

@post_production_history.confirm( @admin ) 

@complete_cycle_sales_item.reload

# creating delivery
@delivery   = Delivery.create_by_employee( @admin , {
  :customer_id    => @customer.id,          
  :delivery_address   => "some address",    
  :delivery_date     => Date.new(2012, 12, 15)
})


#create delivery entry
@pending_delivery = @complete_cycle_sales_item.ready 

@quantity_sent = 1 
if @pending_delivery > 1 
  @quantity_sent = @pending_delivery - 1 
end

@delivery_entry = DeliveryEntry.create_delivery_entry( @admin, @delivery,   {
    :quantity_sent => @quantity_sent, 
    :quantity_sent_weight => "#{@quantity_sent * 10}" ,
    :sales_item_id => @complete_cycle_sales_item.id 
  })
  
#confirm delivery
@complete_cycle_sales_item.reload 
@initial_on_delivery = @complete_cycle_sales_item.on_delivery 

@delivery.confirm( @admin ) 
@complete_cycle_sales_item.reload 
@delivery_entry.reload


# DELIVERY FINALIZATION
@quantity_returned = 0 
@quantity_lost = 3 
@quantity_confirmed =   @delivery_entry.quantity_sent - @quantity_returned  - @quantity_lost 


@delivery_entry.update_post_delivery(@admin, {
  :quantity_confirmed => @quantity_confirmed , 
  :quantity_returned => @quantity_returned ,
  :quantity_returned_weight => "#{@quantity_returned*20}" ,
  :quantity_lost => @quantity_lost  
}) 


@complete_cycle_sales_item.reload 
@initial_on_delivery_item = @complete_cycle_sales_item.on_delivery 
@initial_fulfilled = @complete_cycle_sales_item.fulfilled_order

@initial_pending_production  =  @complete_cycle_sales_item.pending_production 

@delivery.reload 
@delivery.finalize(@admin)
@delivery.reload

# @delivery.finalize(@admin)  
@complete_cycle_sales_item.reload
@delivery_lost = @delivery.delivery_lost