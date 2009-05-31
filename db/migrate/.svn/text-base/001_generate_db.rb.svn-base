class GenerateDb < ActiveRecord::Migration
  def self.up
   
    create_table "permissions", :force => true do |t|
      t.column "name", :string, :limit => 128, :default => "", :null => false
      t.column "info", :text
    end

    create_table "permissions_roles", :id => false, :force => true do |t|
      t.column "role_id",       :integer, :limit => 10, :default => 0, :null => false
      t.column "permission_id", :integer, :limit => 10, :default => 0, :null => false
    end

    #I changed to use both combined index and single index instead of two single index, it's better with MySQL. -H
    #This modification extends to all join tables
    add_index "permissions_roles", ["permission_id","role_id"], :name => "permissions_roles_FKIndex1", :unique => true
    add_index "permissions_roles", ["role_id"], :name => "permissions_roles_FKIndex2", :unique => false

   
    create_table "roles", :force => true do |t|
      t.column "name", :string, :limit => 128, :default => "", :null => false
      t.column "display_name", :string, :limit => 128, :default => "", :null => false
      t.column "description", :text
    end

    create_table "roles_users", :id => false, :force => true do |t|
      t.column "user_id", :integer, :limit => 10, :default => 0, :null => false
      t.column "role_id", :integer, :limit => 10, :default => 0, :null => false
    end

    add_index "roles_users", ["role_id", "user_id"], :name => "roles_users_FKIndex1", :unique => true
    add_index "roles_users", ["user_id"], :name => "roles_users_FKIndex2", :unique => false

    create_table "sessions", :force => true do |t|
      t.column "session_id", :string
      t.column "data",       :text
      t.column "updated_at", :datetime
    end

    add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
    add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

    create_table "users", :force => true do |t|
      t.column "login", :string, :limit => 8,   :default => "", :null => false
      t.column "name",  :string, :limit => 128
      t.column "active", :boolean, :default => true, :null => false
      t.string "first_name", :limit => 20
      t.string "last_name", :limit => 20
      t.string "email", :limit => 128
    end
    
    create_table "groups", :force => true do |t|
      t.column "name", :string, :limit => 128,   :default => "", :null => false
      t.column "info",  :text
    end
    
    create_table "groups_roles", :id => false, :force => true do |t|
      t.column "group_id", :integer, :limit => 10, :default => 0, :null => false
      t.column "role_id", :integer, :limit => 10, :default => 0, :null => false
    end

    add_index "groups_roles", ["group_id","role_id"], :name => "groups_roles_FKIndex1", :unique => true
    add_index "groups_roles", ["role_id"], :name => "groups_roles_FKIndex2", :unique => false
    
    create_table "groups_users", :id => false, :force => true do |t|
      t.column "group_id", :integer, :limit => 10, :default => 0, :null => false
      t.column "user_id", :integer, :limit => 10, :default => 0, :null => false
    end

    add_index "groups_users", ["group_id","user_id"], :name => "groups_users_FKIndex1", :unique => true
    add_index "groups_users", ["user_id"], :name => "groups_users_FKIndex2", :unique => false
    
    
    create_table "departments" do |t|
      t.column "name", :string, :limit => 128, :default => "", :null => false
      t.column "info", :text
      t.column "permission_id", :integer, :limit => 10, :default => 0, :null => false

    end
    
    create_table "departments_users", :id => false, :force => true do |t|
      t.column "department_id",       :integer, :limit => 10, :default => 0, :null => false
      t.column "user_id", :integer, :limit => 10, :default => 0, :null => false
    end
    
    
    add_index "departments_users", ["department_id","user_id"], :name => "departments_users_FKIndex1", :unique => true
    add_index "departments_users", ["user_id"], :name => "departments_users_FKIndex2", :unique => false

    create_table "departments_roles", :id => false, :force => true do |t|
      t.column "department_id",       :integer, :limit => 10, :default => 0, :null => false
      t.column "role_id", :integer, :limit => 10, :default => 0, :null => false
    end

    add_index "departments_roles", ["department_id", "role_id"], :name => "departments_roles_FKIndex1", :unique => true
    add_index "departments_roles", ["role_id"], :name => "departments_roles_FKIndex2", :unique => false

    create_table "departments_groups", :id => false, :force => true do |t|
      t.column "department_id",       :integer, :limit => 10, :default => 0, :null => false
      t.column "group_id", :integer, :limit => 10, :default => 0, :null => false
    end

    add_index "departments_groups", ["department_id", "group_id"], :name => "departments_groups_FKIndex1", :unique => true
    add_index "departments_groups", ["group_id"], :name => "departments_groups_FKIndex2", :unique => false



  end
  
  def self.drop_tables(tables)
    for table in tables
      drop_table table
    end
  end
  
  def self.down
    drop_tables [:permissions, :permissions_roles, :roles, :roles_users, :sessions, :users, :departments, :departments_users, :departments_roles,
    :departments_groups, :groups, :groups_users, :groups_roles, :payforms_payform_items]
  end
end
