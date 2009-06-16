class DataType < ActiveRecord::Base
  belongs_to :department
  has_many :data_objects, :dependent => :destroy
  has_many :data_fields, :dependent => :destroy
  
  validates_uniqueness_of :name
  validates_presence_of   :department_id
end
