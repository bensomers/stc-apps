class CreateShiftConfigurations < ActiveRecord::Migration
  def self.up
    create_table :shift_configurations do |t|
      
      t.integer :department_id
      t.integer :start
      t.integer :end
      t.integer :granularity
      t.integer :grace_period
      t.boolean :report_can_edit, :default => false
      t.string  :useful_links

      t.integer :shift_permission_id
      t.integer :shift_admin_permission_id
      t.integer :department_admin_permission_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :shift_configurations
  end
end
