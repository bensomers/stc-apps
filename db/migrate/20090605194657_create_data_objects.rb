class CreateDataObjects < ActiveRecord::Migration
  def self.up
    create_table :data_objects do |t|
      t.integer :data_type_id
      t.string  :name
      t.string  :description
      t.timestamps
    end
  end
  
  def self.down
    drop_table :data_objects
  end
end
