class AddTimeSlotIndices < ActiveRecord::Migration
  def self.up
    add_index "time_slots", ["start"], :name => "index_slots_on_start_time", :unique => false
    add_index "time_slots", ["end"], :name => "index_slots_on_end_time", :unique => false
  end

  def self.down
    remove_index "time_slots", :name => "index_slots_on_start_time"
    remove_index "time_slots", :name => "index_slots_on_end_time"
  end
end
