class DataType < ActiveRecord::Base
  belongs_to :department
  has_many :data_objects
  has_many :data_fields
  
  validates_uniqueness_of :name
  validates_presence_of   :data_fields_types
end
