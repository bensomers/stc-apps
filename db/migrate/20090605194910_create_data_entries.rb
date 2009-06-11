class CreateDataEntries < ActiveRecord::Migration
  def self.up
    create_table :data_entries do |t|
      t.references :data_object
      t.string     :content
      t.timestamps
    end
  end
  
  def self.down
    drop_table :data_entries
  end
end
