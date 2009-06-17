class DataObject < ActiveRecord::Base
  belongs_to :data_type
  has_many :data_entries, :dependent => :destroy
  has_and_belongs_to_many :locations

  validates_presence_of   :name
  validates_presence_of   :data_type_id
  validates_uniqueness_of :name
  
  def self.by_department(dept)
    dept.location_groups.map{|lg| lg.locations}.flatten.map{|loc| loc.data_objects}.flatten.compact
  end
  
  def self.by_location_group(lg)
    lg.locations.map{|loc| loc.data_objects}.flatten.compact
  end
  
end

