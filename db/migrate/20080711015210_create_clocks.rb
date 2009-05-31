class CreateClocks < ActiveRecord::Migration
  def self.up
    create_table :clocks do |t|
      t.datetime "in"
      t.datetime "out"
      t.datetime "start"
      t.integer  "user_id"
      t.integer  "department_id"
      t.integer  "mass_clock_id"
      t.timestamps
    end
    
    create_table :mass_clocks do |t|
      t.string  "description"
      t.integer "category_id"
      t.integer "department_id"
      t.integer "user_id"
      t.timestamps
    end
  end

  def self.down
    drop_table :clocks
    drop_table :mass_clocks
  end
end
