class WarnManualAddReport < ActiveRecord::Migration
  def self.up
    change_table :shift_reports do |t|
      t.boolean :payform_auto_added, :default => true
    end
  end

  def self.down
    change_table :shift_reports do |t|
      t.remove :payform_auto_added
    end
  end
end
