=begin
  Use this to receive the cast => in the post production only sales item
  
  output => will increase the post production order 
    => pending post production. 
=end
class ItemReceival < ActiveRecord::Base
  # attr_accessible :title, :body
  validates_presence_of :creator_id
  validates_presence_of :customer_id
  
  belongs_to :customer 
  has_many :item_receival_entries 

  def self.create_by_employee( employee, params ) 
    return nil if employee.nil? 
    
    new_object = self.new
    new_object.creator_id                 = employee.id
    new_object.customer_id                = params[:customer_id] 
    new_object.receival_date              = params[:receival_date]
    
    
    if new_object.save
      new_object.generate_code
    end
    
    return new_object 
  end
  
  def delete(employee)
    return nil if employee.nil?
    return nil if self.is_confirmed?
    
    self.item_receival_entries.each do |item_receival_entry|
      item_receival_entry.destroy 
    end
    self.destroy 
  end
  
  def update_by_employee( employee, params ) 
    return nil if employee.nil? 
    
    self.creator_id                 = employee.id
    self.customer_id                = params[:customer_id] 
    self.receival_date              = params[:receival_date]
    
    
    if self.save
    end
    
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
    
    
    string = "#{header}IRC" + "/" + 
              self.created_at.year.to_s + '/' + 
              self.created_at.month.to_s + '/' + 
              counter.to_s 
              
    self.code =  string 
    self.save 
  end
  
  def confirm(employee) 
    return nil if employee.nil? 
    return nil if self.item_receival_entries.count == 0 
    return nil if self.is_confirmed == true  
    
    # transaction block to confirm all the sales item  + sales order confirmation 
    ActiveRecord::Base.transaction do
      self.confirmer_id = employee.id 
      self.confirmed_at = DateTime.now 
      self.is_confirmed = true 
      self.save 
      self.generate_code
      
      if  self.errors.size != 0  
        raise ActiveRecord::Rollback, "Call tech support!" 
      end
      
      self.item_receival_entries.each do |item_receival_entry|
        item_receival_entry.confirm 
      end
    end 
  end
  
end
