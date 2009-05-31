class CreateData < ActiveRecord::Migration
  def self.up
    create_table "data_entries", :force => true do |t|
      t.integer  "data_object_id", :limit => 11
      t.string   "s0"
      t.string   "s1"
      t.string   "s2"
      t.string   "s3"
      t.string   "s4"
      t.string   "s5"
      t.string   "s6"
      t.string   "s7"
      t.string   "s8"
      t.string   "s9"
      t.integer  "i0",             :limit => 11
      t.integer  "i1",             :limit => 11
      t.integer  "i2",             :limit => 11
      t.integer  "i3",             :limit => 11
      t.integer  "i4",             :limit => 11
      t.integer  "i5",             :limit => 11
      t.integer  "i6",             :limit => 11
      t.integer  "i7",             :limit => 11
      t.integer  "i8",             :limit => 11
      t.integer  "i9",             :limit => 11
      t.boolean  "b0"
      t.boolean  "b1"
      t.boolean  "b2"
      t.boolean  "b3"
      t.boolean  "b4"
      t.boolean  "b5"
      t.boolean  "b6"
      t.boolean  "b7"
      t.boolean  "b8"
      t.boolean  "b9"
      t.float    "f0"
      t.float    "f1"
      t.float    "f2"
      t.float    "f3"
      t.float    "f4"
      t.float    "f5"
      t.float    "f6"
      t.float    "f7"
      t.float    "f8"
      t.float    "f9"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "data_objects", :force => true do |t|
      t.integer  "data_type_id", :limit => 11
      t.string   "name"
      t.string   "description"
      t.boolean   "editable"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  
    create_table "data_objects_locations", :id => false, :force => true do |t|
      t.integer "data_object_id", :limit => 10, :default => 0, :null => false
      t.integer "location_id",    :limit => 10, :default => 0, :null => false
    end
  
    add_index "data_objects_locations", ["data_object_id", "location_id"], :name => "data_objects_locations_FKIndex1", :unique => true
    add_index "data_objects_locations", ["location_id"], :name => "data_objects_locations_FKIndex2"
  
    create_table "data_types", :force => true do |t|
      t.string   "name"
      t.integer  "department_id"
      t.string   "s0label"
      t.string   "s1label"
      t.string   "s2label"
      t.string   "s3label"
      t.string   "s4label"
      t.string   "s5label"
      t.string   "s6label"
      t.string   "s7label"
      t.string   "s8label"
      t.string   "s9label"
      t.string   "i0label"
      t.string   "i1label"
      t.string   "i2label"
      t.string   "i3label"
      t.string   "i4label"
      t.string   "i5label"
      t.string   "i6label"
      t.string   "i7label"
      t.string   "i8label"
      t.string   "i9label"
      t.string   "b0label"
      t.string   "b1label"
      t.string   "b2label"
      t.string   "b3label"
      t.string   "b4label"
      t.string   "b5label"
      t.string   "b6label"
      t.string   "b7label"
      t.string   "b8label"
      t.string   "b9label"
      t.string   "f0label"
      t.string   "f1label"
      t.string   "f2label"
      t.string   "f3label"
      t.string   "f4label"
      t.string   "f5label"
      t.string   "f6label"
      t.string   "f7label"
      t.string   "f8label"
      t.string   "f9label"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

  end

  def self.down
    drop_table :data_entries
    drop_table :data_objects
    drop_table :data_types
    drop_table :data_objects_locations
    
  end
end
