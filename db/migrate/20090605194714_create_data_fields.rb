class CreateDataFields < ActiveRecord::Migration
  def self.up
    create_table :data_fields do |t|
<<<<<<< HEAD:db/migrate/20090605194714_create_data_fields.rb
      t.integer    :data_type_id
=======
      t.references :data_type    
>>>>>>> 8f12bb65c1fbd361562ebcaeab0c6a8a99ad37cb:db/migrate/20090605194714_create_data_fields.rb
      t.string     :name
      t.string     :display_type
      t.string     :values
      t.timestamps
    end
  end
  
  def self.down
    drop_table :data_fields
  end
end
