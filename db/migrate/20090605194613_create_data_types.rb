class CreateDataTypes < ActiveRecord::Migration
  def self.up
    create_table :data_types do |t|
<<<<<<< HEAD:db/migrate/20090605194613_create_data_types.rb
      t.string     :name
      t.text       :description
      t.integer    :department_id
      t.string     :data_fields_types
=======
      t.string      :name
      t.text        :description
      t.references  :department  #should we use t.references?
>>>>>>> 8f12bb65c1fbd361562ebcaeab0c6a8a99ad37cb:db/migrate/20090605194613_create_data_types.rb
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :data_types
  end
end
