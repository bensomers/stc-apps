class DataField < ActiveRecord::Base
  # options for select; these are the allowable data field display types
  DISPLAY_TYPE_OPTIONS = {"Text Field"   => "text_field", 
                          "Text Area"    => "text_area",
                          "Select Box"   => "select", 
                          "Radio Button" => "radio_button",
                          "Check Boxes"  => "check_box"}  
  
  belongs_to :data_type

end
