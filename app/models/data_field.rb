class DataField < ActiveRecord::Base
  has_and_belongs_to_many :data_types
end
