class CashAccount < ActiveRecord::Base
  attr_accessible :name, :case, :description 
  validates_presence_of :name, :case
  
  has_many :payments  
  
  def CashAccount.all_selectable_cases
    result = []
    CASH_ACCOUNT_CASE.each do |key, cac | 
      
      result << [ "#{cac[:name]}" , 
                      cac[:value] ]  
    end
    return result
  end
  
  def self.all_selectables
    selectables  =  CashAccount.order("created_at DESC") 
    result = []
    selectables.each do |selectable| 
      result << [ "#{selectable.name}" , 
                      selectable.id ]  
    end
    return result
  end
  
  def delete( employee )
    return nil if employee.nil?
    return nil if self.payments.count != 0
    self.destroy
  end
end
