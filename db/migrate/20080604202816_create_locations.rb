class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.references :location_group
      
      t.string :long_name
      t.string :short_name
      t.string :report_email
      t.string :useful_links
      t.integer :max_staff
      t.integer :priority
      t.integer :min_staff
      t.integer :max_staff
      t.boolean :active, :default => true

      t.timestamps
    end
  end

  def self.down
    drop_table :locations
  end
end
