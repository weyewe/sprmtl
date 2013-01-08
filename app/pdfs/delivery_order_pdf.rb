class DeliveryOrderPdf < Prawn::Document
  
  # def initialize(invoice, view)
  #   super()
  #   @delivery_order = invoice
  #   @view = view
  #   text "Invoice #{@delivery_order.printed_sales_invoice_code}"
  # end
  
  
  
  
  def initialize(delivery_order , view, page_width, page_length)
    super(:page_size =>  [page_width, page_length])  #[width,length]
    @page_width = page_width
    @page_length = page_length
    @delivery_order = delivery_order
    @view = view
    # page_size  [684, 792]
    font("Courier")
    
    # text "My report caption", :size => 18, :align => :right
    # move_down font.height * 2
    
    
    title 
    move_down 20 
    company_customer_details 
    
    subscription_details
    # subscription_details
    # subscription_amount
    regards_message
    
    page_numbering 
  end
   
   
  def title
    bounding_box( [150,cursor], :width => @page_width - 300) do
      text "Delivery: #{@delivery_order.code}", 
          :size => 15, 
          :align => :center 
          
      confirmed_date =  @delivery_order.confirmed_at.in_time_zone(LOCAL_TIME_ZONE)
      text "Date: #{confirmed_date.day}/#{confirmed_date.month}/#{confirmed_date.year}", 
          :size => 12, 
          :align => :center
    end 
  end
  
  def company_customer_details
    gap = 0 
    box_separator = 20 
    
    half_page = @page_width/2
    width = half_page - box_separator
    @company = Company.first 
    
    @customer = @delivery_order.customer
    
    bounding_box( [0,cursor], :width => @page_width) do
      bounding_box([gap, bounds.top - gap], :width => width) do 
        text  "Bangjay"  #{}"#{@company.name}"
        text  "Alamat Bangjay"  #}"#{@company.address}"
        text  "telpon bangjay" #  "#{@company.phone}"
      end
      
      if not @customer.nil?
        bounding_box([half_page + box_separator, bounds.top - gap], :width => width) do 
          text "#{@customer.name}"
          text 'Kompleks Pergudangan Rawa Lele nomor 3315'
        end 
      end
    end
  end
   
  def thanks_message
    move_down 80
    text "Hello Customer Name" #"Hello #{@delivery_order.customer.profile.first_name.capitalize},"
    move_down 15
    text "Thank you for your order.Print this receipt as confirmation of your order.",
    :indent_paragraphs => 40, :size => 13
  end
   
  def subscription_date
    move_down 40
    text "Subscription start date:
   #{@delivery_order.created_at.strftime("%d/%m/%Y")} ", :size => 13
    move_down 20
    text "Subscription end date : 
   #{@delivery_order.updated_at.strftime("%d/%m/%Y")}", :size => 13
  end
   
  def subscription_details
    move_down 40
    total_active_sales_entries = @delivery_order.delivery_entries.count 
    
    table subscription_item_rows , :position => :center , :width => @page_width -100 do
      row(0).font_style = :bold
      row( total_active_sales_entries + 1).font_style = :bold 
      columns(1..3).align = :left
      self.header = true
      self.column_widths = { 1 => 400 }
    end
    
    
    # table subscription_item_rows do
    #   row(0).font_style = :bold
    #   columns(1..3).align = :right
    #   self.header = true
    #   self.column_widths = {0 => 100, 1 => 200, 2 => 100, 3 => 100, 4 => 100}
    # end
  end
   
  def subscription_amount
    subscription_amount = @delivery_order.total_amount_to_be_paid
    vat = @delivery_order.calculated_vat
    delivery_charges = @delivery_order.calculated_delivery_charges
    sales_tax =  @delivery_order.calculated_sales_tax
    table ([
      ["", "Vat (12.5% of Amount)", "", "", "#{precision(vat)}"] ,
      ["","Sales Tax (10.3% of half the Amount)", "", "",
              "#{precision(sales_tax)}"]   ,
      ["", "Delivery charges", "", "", "#{precision(delivery_charges)}  "],
      ["", "", "", "Total Amount", "#{precision(@delivery_order.total_amount_to_be_paid) }  "]
    # ]),
    #  :width => 500 do
    ]) do 
      columns(2).align = :left
      columns(3).align = :left
      self.header = true
      self.column_widths = {0 => 200, 1 => 100, 2 => 100, 3 => 100}
      columns(2).font_style = :bold
    end
  end
   
  def subscription_item_rows
    count = 0
    total_price_in_sales_order = BigDecimal("0")
    
    [["No", "Item", "Quantity", "Diterima", "Retur", "Hilang"]] +
    (@delivery_order.delivery_entries).map do |delivery_entry|
      count = count + 1 
      sales_item = delivery_entry.sales_item
      item_data = "#{sales_item.code} "  
      item_data << "\n"
      item_data << "#{sales_item.name}" 
       
      [ "#{count}", 
        "#{item_data} ", delivery_entry.quantity_sent,
        '',
        '',
        ''
       ]
    end   
  end
   
  def precision(num)
    @view.number_with_precision(num, :precision => 2)
  end
   
  def regards_message
    move_down 50
    # text "Thank You," ,:indent_paragraphs => 400
    move_down 6
    # text "XYZ",
    # :indent_paragraphs => 370, :size => 14, style:  :bold
  end
  
  def page_numbering
    string = "<page> / <total>" # Green page numbers 1 to 7
    options = {
      :at => [bounds.right - 150, bounds.top], 
      :width => 150, :align => :right, 
      :start_count_at => 1 
    } 
    number_pages string, options
  end
 
end