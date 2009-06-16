class DataObject < ActiveRecord::Base
  belongs_to :data_type
  has_many :data_entries
  has_and_belongs_to_many :locations

  validates_presence_of   :name
  validates_presence_of   :data_type_id
  validates_presence_of   :location_id
  validates_uniqueness_of :name
  validates_uniqueness_of :location_id
end

