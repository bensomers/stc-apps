class DataField < ActiveRecord::Base
  # options for select; these are the allowable data field display types
  DISPLAY_TYPE_OPTIONS = {"Text Field"   => "text_field", 
                          "Paragraph Text"    => "text_area",
                          "Select from a List"   => "select", 
                          "Multiple Choice" => "radio_button",
                          "Check Boxes" => "check_box"}  
  
  belongs_to :data_type

  #This should probably be moved to the data_entries helper
  #Based on the display type, returns the arguments for the formhelper methods
  def parse_display_and_values
    if display_type == "text_field"
      return ["data_fields", id, {:id => id}]
    elsif display_type == "text_area"
      return ["data_fields", id]
    elsif display_type == "select"
      options = values.split(',').each{|opt| opt.squish!}
      return ["data_fields", id, options.map{|opt| [opt, opt]}]
    elsif display_type == "check_box"
      options = values.split(',').each{|opt| opt.squish!}
      return options.map{|v| ["data_fields[#{id}]", v]}
    elsif display_type == "radio_button"
      options = values.split(',').each{|opt| opt.squish!}
      return options.map{|v| ["data_fields[#{id}]", 1, v]}
    end   
  end

  end
