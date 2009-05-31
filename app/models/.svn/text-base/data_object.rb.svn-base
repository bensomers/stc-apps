class DataObject < ActiveRecord::Base

  has_many :data_entries, :dependent => :destroy
  belongs_to :data_type
  has_and_belongs_to_many :locations
  
  validates_uniqueness_of :name
    
end
