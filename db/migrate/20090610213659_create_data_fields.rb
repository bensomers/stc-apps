class CreateDataFields < ActiveRecord::Migration
  def self.up
    create_table :data_fields do |t|
      t.string      :label
      t.string      :value
      t.string      :display_type
      t.integer     :data_type_id
      t.timestamps
    end
  end
  
  def self.down
    drop_table :data_fields
  end
end
