class DataField < ActiveRecord::Base
  OPTIONS_ARRAY = ["check_box", "form", "select", "text_area", "text_field"]  #options for what a data_field can be
  has_and_belongs_to_many :data_types
end
