class DataObject < ActiveRecord::Base
  belongs_to :data_type
  has_many :data_entries
  has_and_belongs_to_many :locations
  
  validates_uniqueness_of :name
end
