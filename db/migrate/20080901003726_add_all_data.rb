require 'active_record/fixtures'

class AddAllData < ActiveRecord::Migration
  def self.up
    down
    env_dir = ENV['RAILS_ENV'] =='production' ? "production_data" : "development_data"
    directory = File.join(File.dirname(__FILE__), env_dir)
    self.add_fixtures ["location_groups", "locations", "shifts", "time_slots", "shift_reports", "line_items", "libraries", "template_items", "shift_configurations", "data_types", "data_objects", "data_objects_locations", "preferences"], directory
  end
  
  def self.add_fixtures(fixtures, directory)
    for fixture in fixtures
      Fixtures.create_fixtures(directory, fixture)
    end
  end

  def self.down
    Location.delete_all    
    LocationGroup.delete_all
    Shift.delete_all
    TimeSlot.delete_all
    ShiftReport.delete_all
    LineItem.delete_all
    Library.delete_all
    TemplateItem.delete_all
    ShiftConfiguration.delete_all
    DataType.delete_all
    DataObject.delete_all
    Preference.delete_all
  end
end
