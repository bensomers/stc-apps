class CreateDataFieldsDataTypes < ActiveRecord::Migration
  def self.up
    create_table :data_fields_data_types do |t|
      t.integer :data_field_id
      t.integer :data_type_id

      t.timestamps
    end
  end

  def self.down
    drop_table :data_fields_data_types
  end
end
