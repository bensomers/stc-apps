class AddShiftIndices < ActiveRecord::Migration
  def self.up
    add_index "shifts", ["start"], :name => "index_shifts_on_start_time", :unique => false
    add_index "shifts", ["end"], :name => "index_shifts_on_end_time", :unique => false
  end

  def self.down
    remove_index "shifts", :name => "index_shifts_on_start_time"
    remove_index "shifts", :name => "index_shifts_on_end_time"
  end
end
