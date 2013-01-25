class DeliveryEntry < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :delivery
  belongs_to :sales_item 
  has_one :sales_return_entry
  
  
  
  validate   :quantity_sent_is_not_zero_and_less_than_ready_quantity
  validate   :quantity_sent_weight_is_not_zero_and_less_than_ready_quantity 
  validate   :uniqueness_of_sales_item
  validate   :customer_ownership_to_sales_item
  
  def quantity_sent_is_not_zero_and_less_than_ready_quantity
    sales_item = self.sales_item
    if  self.normal_delivery_entry?  and  self.delivery.is_confirmed == false and ( quantity_sent <= 0 or quantity_sent > sales_item.ready ) 
      errors.add(:quantity_sent , "Kuantitas harus lebih dari 0 dan kurang atau sama dengan #{sales_item.ready}" )  
    end
    
    if self.entry_case == DELIVERY_ENTRY_CASE[:guarantee_return] and 
        self.delivery.is_confirmed == false and ( quantity_sent <= 0 or quantity_sent > sales_item.pending_guarantee_return_delivery)
      errors.add(:quantity_sent , "Kuantitas harus lebih dari 0 dan kurang atau sama dengan #{sales_item.ready} (pengembalian retur garansi)" )  
    end
  end
  
  def quantity_sent_weight_is_not_zero_and_less_than_ready_quantity
    if  quantity_sent_weight <= BigDecimal('0') 
      errors.add(:quantity_sent_weight , "Berat tidak boleh kurang dari 0kg" )  
    end
  end
  
  def uniqueness_of_sales_item
    # but allow it, if it is from different CASE 
    parent  = self.delivery
    sales_item_id_list = parent.delivery_entries.map{|x| x.sales_item_id }
    post_uniq_sales_item_id_list = sales_item_id_list.uniq 
   
   
    delivery_entry_count = DeliveryEntry.where(
      :sales_item_id => self.sales_item_id,
      :delivery_id => parent.id ,
      :entry_case => self.entry_case 
    ).count 
    
    # if not self.persisted? and post_uniq_sales_item_id_list.include?( self.sales_item_id)
    #   errors.add(:sales_item_id , "Sales item #{self.sales_item.code} sudah terdaftar di surat jalan" ) 
    # elsif self.persisted? and sales_item_id_list.length !=  post_uniq_sales_item_id_list.length
    #   errors.add(:sales_item_id , "Sales item #{self.sales_item.code} sudah terdaftar di surat jalan" ) 
    # end
    
    # i want to check.. if there has been such delivery entry with  similar entry_case and sales_item_id 
    # =>  error 
    if not self.persisted? and delivery_entry_count != 0
      errors.add(:sales_item_id , "Sales item #{self.sales_item.code} sudah terdaftar di surat jalan" ) 
    elsif self.persisted? and delivery_entry_count != 1 
      errors.add(:sales_item_id , "Sales item #{self.sales_item.code} sudah terdaftar di surat jalan" ) 
    end
    
    
  end
  
  def customer_ownership_to_sales_item
    parent = self.delivery
    if delivery.customer_id != self.sales_item.sales_order.customer_id 
      errors.add(:sales_item_id , "Sales item #{self.sales_item.code} tidak terdaftar di daftar penjualan." ) 
    end
  end
  
  
  
  def DeliveryEntry.create_delivery_entry( employee, delivery,  params ) 
    return nil if employee.nil?
    
    new_object = DeliveryEntry.new
    new_object.creator_id = employee.id 
    new_object.delivery_id = delivery.id 
    new_object.sales_item_id = params[:sales_item_id] 
    
    new_object.quantity_sent        = params[:quantity_sent]       
    new_object.quantity_sent_weight = BigDecimal( params[:quantity_sent_weight ])
    new_object.entry_case           = params[:entry_case] 

    
    new_object.generate_delivery_entry_case
    if new_object.save 
      new_object.generate_code 
      
    end
    
    return new_object 
  end
  
  def update_delivery_entry( employee, delivery,  params ) 
    return nil if employee.nil?
    
   
    self.creator_id           = employee.id 
    self.delivery_id          = delivery.id 
    self.sales_item_id        = params[:sales_item_id] 
    self.quantity_sent        = params[:quantity_sent]       
    self.quantity_sent_weight = BigDecimal( params[:quantity_sent_weight ])
    self.entry_case           = params[:entry_case] 

    new_object.generate_delivery_entry_case
    if self.save 
    end
    
    return self 
  end
  
  def delete( employee )
    return nil if employee.nil?
    return nil if self.is_confirmed? 
    
    self.destroy 
  end
  
  def validate_post_production_quantity 
    if quantity_confirmed.nil? or quantity_confirmed < 0 
      self.errors.add(:quantity_confirmed , "Tidak boleh kurang dari 0" ) 
    end
    
    if quantity_returned.nil? or quantity_returned < 0 
      self.errors.add(:quantity_returned , "Tidak boleh kurang dari 0" ) 
    end
    
    if quantity_lost.nil? or quantity_lost < 0 
      self.errors.add(:quantity_lost , "Tidak boleh kurang dari 0" ) 
    end
  end
  
  def validate_post_production_total_sum
    if self.quantity_confirmed + self.quantity_returned + self.quantity_lost != self.quantity_sent 
      msg = "Jumlah yang terkirim: #{self.quantity_sent}. " +
              "Konfirmasi #{self.quantity_confirmed} + " + 
              " Retur #{self.quantity_returned }+ " + 
              " Hilang #{self.quantity_lost} tidak sesuai."
      self.errors.add(:quantity_confirmed , msg ) 
      self.errors.add(:quantity_returned ,  msg ) 
      self.errors.add(:quantity_lost ,      msg ) 
    end
  end
  
  def validate_returned_item_quantity_weight  
    if self.quantity_returned == 0 and self.quantity_returned_weight.to_i !=  0 
      self.errors.add(:quantity_returned_weight , "Tidak ada yang di retur. Harus 0" )  
    end
  end
  
  
  def validate_post_production_update 
    self.validate_post_production_quantity 
    # puts "after validate_post_production_quantity, errors: #{self.errors.size.to_s}"
    
    self.validate_post_production_total_sum   
    # puts "after validate_post_production_total_sum, errors: #{self.errors.size.to_s}"
    
    self.validate_returned_item_quantity_weight 
    # puts "after validate_returned_item_quantity_weight, errors: #{self.errors.size.to_s}"
    
  end
    
  def update_post_delivery( employee, params ) 
    return nil if employee.nil? 
    return nil if not self.is_confirmed?
    
    
    # puts "confirmed: #{params[:quantity_confirmed]}"
    # puts "quantity_returned: #{params[:quantity_returned]}"
    # puts "quantity_lost: #{params[:quantity_lost]}"
    
    self.quantity_confirmed        = params[:quantity_confirmed]
    self.quantity_confirmed_weight = BigDecimal( params[:quantity_confirmed_weight] ) 
    


    self.quantity_returned         = params[:quantity_returned]
    self.quantity_returned_weight  = BigDecimal( params[:quantity_returned_weight] )


    self.quantity_lost             = params[:quantity_lost]

    
    
    
    self.validate_post_production_update
    puts "after validate_post_production_update, errors: #{self.errors.size.to_s}"
    self.errors.messages.each do |message|
      puts "The message: #{message}"
    end
    
    return self if  self.errors.size != 0 
    # puts "Not supposed to be printed out if there is error"
    self.save  
    return self  
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
    
    string = "#{header}DE" + "/" + 
              self.created_at.year.to_s + '/' + 
              self.created_at.month.to_s+ '/' + 
              counter.to_s
              
    self.code =  string 
    self.save 
  end
  
  def validate_pricing_availability
    sales_item = self.sales_item
    
    if sales_item.is_pending_pricing == true  
      errors.add(:pricing , "Harga untuk sales item ini belum tersedia" )  
    end
  end
  
  def generate_delivery_entry_case 
    if self.entry_case.nil? 
      sales_item  = self.sales_item 
      if sales_item.is_post_production? # contains post production.. don't really care about production 
        self.entry_case = DELIVERY_ENTRY_CASE[:ready_post_production]
      elsif sales_item.only_production?
        self.entry_case = DELIVERY_ENTRY_CASE[:ready_production]
      end
    end
  end
  
  def confirm 
    return nil if self.is_confirmed == true  
    self.is_confirmed = true 
    
    self.save 
    
    self.generate_code
    
    self.generate_delivery_entry_case 
    
    validate_pricing_availability
    
    if  self.errors.size != 0  
      raise ActiveRecord::Rollback, "Call tech support!" 
    end
    
    sales_item = self.sales_item 
    
    sales_item.update_on_delivery_confirm
    # sales_item.update_on_delivery_statistics
    # sales_item.update_ready_statistics
  end
  
  def finalize
    return nil if self.is_confirmed == false 
    return nil if self.is_finalized == true 
    
    # puts "finalizing shite\n"*10
    
    # puts "before finalize delivery_entry"
    # puts "confirmed: #{self.quantity_confirmed}"
    # puts "quantity_returned: #{self.quantity_returned}"
    # puts "quantity_lost: #{self.quantity_lost}"
     
    self.validate_post_production_update
    
    if  self.errors.size != 0 
      puts("AAAAAAAAAAAAAAAA THe sibe kia is NOT  valid")
      
      self.errors.messages.each do |key, values| 
        puts "The key is #{key.to_s}"
        values.each do |value|
          puts "\tthe value is #{value}"
        end
      end
      
      raise ActiveRecord::Rollback, "Call tech support!" 
    end
    
    
    
    self.is_finalized = true 
    self.save
    
    
    # puts "&&&&&&&&&&&&&&&&&&BEFORE UPDATING ON FINALIZE\n"*10
    sales_item = self.sales_item 
    
    # depend on the delivery case 
    # if it is the normal  ( entry_case is according to what it is ordered)
    if self.normal_delivery_entry? 
      sales_item.update_on_delivery_item_finalize 
    elsif self.entry_case == DELIVERY_ENTRY_CASE[:guarantee_return] 
      puts "This is the DELIVERY_ENTRY_CASE[:guarantee_return]\n"*10
      sales_item.update_on_guarantee_return_delivery_item_finalize
    end
    
    
    # if it is the case of guarantee_sales_return 
    # => update pending delivery 
    
    # if it is the case of failure / bad source 
    # => update pending failure / bad source delivery 
    
    # if it is emergency return.. WTF.. ordered post production as well. 
  end
  
  def self.all_selectable_delivery_entry_cases
    result = []
    
    result << [ "#{DELIVERY_ENTRY_CASE_VALUE[:ready_production]}" , 
                    DELIVERY_ENTRY_CASE[:ready_production] ] 
                    
    result << [ "#{DELIVERY_ENTRY_CASE_VALUE[:ready_post_production]}" , 
                    DELIVERY_ENTRY_CASE[:ready_post_production] ] 
    
    result << [ "#{DELIVERY_ENTRY_CASE_VALUE[:guarantee_return]}" , 
                    DELIVERY_ENTRY_CASE[:guarantee_return] ] 
    result << [ "#{DELIVERY_ENTRY_CASE_VALUE[:bad_source_fail_post_production]}" , 
                    DELIVERY_ENTRY_CASE[:bad_source_fail_post_production] ]
                    
    result << [ "#{DELIVERY_ENTRY_CASE_VALUE[:technical_failure_post_production]}" , 
                    DELIVERY_ENTRY_CASE[:technical_failure_post_production] ]
    return result
  end
  
  def normal_delivery_entry?
    sales_item = self.sales_item
    if sales_item.only_production?
      return self.entry_case == DELIVERY_ENTRY_CASE[:ready_production]
    elsif sales_item.is_post_production? 
      return self.entry_case == DELIVERY_ENTRY_CASE[:ready_post_production]
    end
  end
  
  def billed_quantity
    quantity = 0 
    if delivery.is_confirmed? and  not delivery.is_finalized? 
      quantity = self.quantity_sent  
    elsif delivery.is_confirmed? and  delivery.is_finalized? 
      quantity = self.quantity_confirmed 
    end
    
    return quantity 
  end
  
  def billed_weight
    weight = 0 
    if delivery.is_confirmed? and  not delivery.is_finalized? 
      weight = self.quantity_sent_weight
    elsif delivery.is_confirmed? and  delivery.is_finalized? 
      weight = self.quantity_confirmed_weight
    end
    
    return weight
  end
  
  def total_delivery_entry_price
    sales_item = self.sales_item 
    quantity = 0 
    weight = BigDecimal('0')
    if delivery.is_confirmed?  and not delivery.is_finalized?
      quantity = self.quantity_sent
      weight = self.quantity_sent_weight 
    elsif  delivery.is_confirmed?  and  delivery.is_finalized?
      quantity = self.quantity_confirmed
      weight = self.quantity_confirmed_weight 
    end 
    
    total_amount = BigDecimal("0")
    
    if self.normal_delivery_entry? 
      if sales_item.is_pre_production?
        total_amount += sales_item.pre_production_price * quantity
      end
    
      if sales_item.is_production? 
        if sales_item.is_pricing_by_weight? 
          total_amount += sales_item.production_price * weight
        else
          total_amount += sales_item.production_price * quantity
        end
      end
  
    
      if sales_item.is_post_production?
        total_amount += sales_item.post_production_price * quantity
      end
    else
      if self.entry_case == DELIVERY_ENTRY_CASE[:guarantee_return]
        # price == FREE 
      end
      
      if self.entry_case == DELIVERY_ENTRY_CASE[:technical_failure_post_production]
        # price == FREE.. in fact.. we have to pay this guy some $$$ 
      end
      
      if self.entry_case == DELIVERY_ENTRY_CASE[:bad_source_fail_post_production]
        total_amount += sales_item.post_production_price * quantity
      end
       
    end
    
    return total_amount
  end
  
end
