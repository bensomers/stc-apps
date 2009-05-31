class MassClock < ActiveRecord::Base
  belongs_to :user
  belongs_to :department
  belongs_to :category
  has_many :payform_items
  has_many :clocks
  
  validates_presence_of :description
  
  
end
