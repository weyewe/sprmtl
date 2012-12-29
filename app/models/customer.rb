class Customer < ActiveRecord::Base
  attr_accessible :name, :contact_person, :phone, :mobile , :email, :bbm_pin, :address, :town_id , :office_address, :delivery_address
  has_many :vehicles 
  
  validates_presence_of :name 
  # validates_uniqueness_of :name
  
  has_many :sales_orders 
  belongs_to :town 
  
  validate :unique_non_deleted_name 
  
  def unique_non_deleted_name
    current_service = self
     
     # claim.status_changed?
    if not current_service.name.nil? 
      if not current_service.persisted? and current_service.has_duplicate_entry?  
        errors.add(:name , "Sudah ada customer  dengan nama sejenis" )  
      elsif current_service.persisted? and 
            current_service.name_changed?  and
            current_service.has_duplicate_entry?   
            # if duplicate entry is itself.. no error
            # else.. some error
            
          if current_service.duplicate_entries.count ==1  and 
              current_service.duplicate_entries.first.id == current_service.id 
          else
            errors.add(:name , "Sudah ada customer  dengan nama sejenis" )  
          end 
      end
    end
  end
  
  def has_duplicate_entry?
    current_service=  self  
    self.class.find(:all, :conditions => ['lower(name) = :name and is_deleted = :is_deleted ', 
                {:name => current_service.name.downcase, :is_deleted => false }]).count != 0  
  end
  
  def duplicate_entries
    current_service=  self  
    return self.class.find(:all, :conditions => ['lower(name) = :name and is_deleted = :is_deleted ', 
                {:name => current_service.name.downcase, :is_deleted => false }]) 
  end
  
  def new_vehicle_registration( employee ,  vehicle_params ) 
    id_code = vehicle_params[:id_code]
    if not id_code.present? 
      return nil
    end
    
    
    self.vehicles.create :id_code =>  id_code.upcase.gsub(/\s+/, "") 
  end
  
  def self.active_customers
    self.where(:is_deleted => false).order("created_at DESC")
  end
  
  def delete
    self.is_deleted = true
    self.save 
  end
end
