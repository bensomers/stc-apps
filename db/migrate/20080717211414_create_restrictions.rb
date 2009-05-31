class CreateRestrictions < ActiveRecord::Migration
  def self.up
    create_table :restrictions do |t|
      t.integer   "max_subs"
      t.decimal   "hours_limit", :precision => 5, :scale => 2
      t.datetime  "starts"
      t.datetime  "expires"
      t.integer   "location_id"
      t.integer   "location_group_id"
      t.integer   "for_department_id"
      t.integer   "department_id"

      t.timestamps #created_at and updated_at
    end
    
    create_table "locations_restrictions", :id => false, :force => true do |t|
      t.integer "restriction_id", :limit => 10, :default => 0, :null => false
      t.integer "location_id",    :limit => 10, :default => 0, :null => false
    end
    create_table "location_groups_restrictions", :id => false, :force => true do |t|
      t.integer "restriction_id",    :limit => 10, :default => 0, :null => false
      t.integer "location_group_id", :limit => 10, :default => 0, :null => false
    end
  end

  def self.down
    drop_table :restrictions
  end
end
