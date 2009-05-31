class CreatePreferences < ActiveRecord::Migration
  def self.up
    create_table :preferences do |t|
      t.integer :user_id
      t.boolean :show_bars, :default => true
      t.string :hide_location_groups

      t.timestamps
    end
  end

  def self.down
    drop_table :preferences
  end
end
