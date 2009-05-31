class CreateNotices < ActiveRecord::Migration
  def self.up
    create_table :notices do |t|
      
      t.string :type
      t.string :content, :limit => 1000
      t.references :author
      t.datetime :start_time, :end_time
      
      #instead of join tables
      t.string :auth_users, :default => "", :limit => 1000
      t.string :auth_locations, :default => "", :limit => 1000
      t.string :auth_location_groups, :default => "", :limit => 1000
      t.integer :for_department_id
      
      
      #for Announcement
      t.references :department
      
      #for Sticky
      t.references :remover
    end
  end

  def self.down
    drop_table :notices
  end
end
