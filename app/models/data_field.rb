class DataField < ActiveRecord::Base
  # options for select; these are the allowable data field display types
  DISPLAY_TYPE_OPTIONS = {"Text Field" => "text_field", 
                          "Text Area" => "text_area",
                          "Select Box" => "select", 
                          "Radio Button" => "radio_button",
                          "Check Boxes" => "check_box"}  
  
  has_and_belongs_to_many :data_types

end
