class AddAnnouncementTables < ActiveRecord::Migration
  def self.up
    
    create_table "announcements_users", :id => false, :force => true do |t|
      t.column "announcement_id",       :integer, :limit => 10, :default => 0, :null => false
      t.column "user_id", :integer, :limit => 10, :default => 0, :null => false
    end
    create_table "announcements_locations", :id => false, :force => true do |t|
      t.column "announcement_id",       :integer, :limit => 10, :default => 0, :null => false
      t.column "location_id", :integer, :limit => 10, :default => 0, :null => false
    end
    create_table "announcements_location_groups", :id => false, :force => true do |t|
      t.column "announcement_id",       :integer, :limit => 10, :default => 0, :null => false
      t.column "location_group_id", :integer, :limit => 10, :default => 0, :null => false
    end
  end

  def self.down
    drop_tables [:announcements_users, :announcements_locations, :announcements_location_groups]
  end
end
