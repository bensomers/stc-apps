class FoodItem < ActiveRecord::Base
  validates_uniqueness_of :name
  validates_numericality_of :price, :message => "is not a number"
  
  named_scope :all_available, :conditions => {:available => true}
end
