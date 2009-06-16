class DataObject < ActiveRecord::Base
  belongs_to :data_type
  has_many :data_entries, :dependent => :destroy
  has_and_belongs_to_many :locations
  
  validates_uniqueness_of :name
  validates_presence_of :data_type_id
end
