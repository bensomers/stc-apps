class DataType < ActiveRecord::Base
  belongs_to :department
  has_many :data_objects
  has_many :data_fields
end
