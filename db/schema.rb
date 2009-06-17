# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090605194910) do

  create_table "announcements_location_groups", :id => false, :force => true do |t|
    t.integer "announcement_id",   :limit => 10, :default => 0, :null => false
    t.integer "location_group_id", :limit => 10, :default => 0, :null => false
  end

  create_table "announcements_locations", :id => false, :force => true do |t|
    t.integer "announcement_id", :limit => 10, :default => 0, :null => false
    t.integer "location_id",     :limit => 10, :default => 0, :null => false
  end

  create_table "announcements_users", :id => false, :force => true do |t|
    t.integer "announcement_id", :limit => 10, :default => 0, :null => false
    t.integer "user_id",         :limit => 10, :default => 0, :null => false
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.boolean  "active",        :default => true
    t.integer  "department_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "clocks", :force => true do |t|
    t.datetime "in"
    t.datetime "out"
    t.datetime "start"
    t.integer  "user_id"
    t.integer  "department_id"
    t.integer  "mass_clock_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "data_entries", :force => true do |t|
    t.integer  "data_object_id"
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "data_fields", :force => true do |t|
    t.integer  "data_type_id"
    t.string   "name"
    t.string   "display_type"
    t.string   "values"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "data_objects", :force => true do |t|
    t.integer  "data_type_id"
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "data_objects_locations", :id => false, :force => true do |t|
    t.integer "data_object_id"
    t.integer "location_id"
  end

  create_table "data_types", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "department_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "departments", :force => true do |t|
    t.string  "name",          :limit => 128, :default => "", :null => false
    t.text    "info"
    t.integer "permission_id", :limit => 10,  :default => 0,  :null => false
  end

  create_table "departments_groups", :id => false, :force => true do |t|
    t.integer "department_id", :limit => 10, :default => 0, :null => false
    t.integer "group_id",      :limit => 10, :default => 0, :null => false
  end

  add_index "departments_groups", ["department_id", "group_id"], :name => "departments_groups_FKIndex1", :unique => true
  add_index "departments_groups", ["group_id"], :name => "departments_groups_FKIndex2"

  create_table "departments_roles", :id => false, :force => true do |t|
    t.integer "department_id", :limit => 10, :default => 0, :null => false
    t.integer "role_id",       :limit => 10, :default => 0, :null => false
  end

  add_index "departments_roles", ["department_id", "role_id"], :name => "departments_roles_FKIndex1", :unique => true
  add_index "departments_roles", ["role_id"], :name => "departments_roles_FKIndex2"

  create_table "departments_users", :id => false, :force => true do |t|
    t.integer "department_id", :limit => 10, :default => 0, :null => false
    t.integer "user_id",       :limit => 10, :default => 0, :null => false
  end

  add_index "departments_users", ["department_id", "user_id"], :name => "departments_users_FKIndex1", :unique => true
  add_index "departments_users", ["user_id"], :name => "departments_users_FKIndex2"

  create_table "edit_items", :force => true do |t|
    t.decimal  "hours",                           :precision => 5, :scale => 2
    t.text     "description",     :limit => 1000
    t.date     "date"
    t.text     "reason",          :limit => 1000
    t.integer  "category_id"
    t.integer  "payform_item_id"
    t.string   "edited_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "food_items", :force => true do |t|
    t.string   "name"
    t.decimal  "price",      :precision => 3, :scale => 2,                   :null => false
    t.boolean  "available",                                :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", :force => true do |t|
    t.string "name", :limit => 128, :default => "", :null => false
    t.text   "info"
  end

  create_table "groups_roles", :id => false, :force => true do |t|
    t.integer "group_id", :limit => 10, :default => 0, :null => false
    t.integer "role_id",  :limit => 10, :default => 0, :null => false
  end

  add_index "groups_roles", ["group_id", "role_id"], :name => "groups_roles_FKIndex1", :unique => true
  add_index "groups_roles", ["role_id"], :name => "groups_roles_FKIndex2"

  create_table "groups_users", :id => false, :force => true do |t|
    t.integer "group_id", :limit => 10, :default => 0, :null => false
    t.integer "user_id",  :limit => 10, :default => 0, :null => false
  end

  add_index "groups_users", ["group_id", "user_id"], :name => "groups_users_FKIndex1", :unique => true
  add_index "groups_users", ["user_id"], :name => "groups_users_FKIndex2"

  create_table "iotabs", :force => true do |t|
    t.integer  "user_id"
    t.integer  "food_item_id"
    t.integer  "paid"
    t.integer  "unpaid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "libraries", :force => true do |t|
    t.string   "type"
    t.integer  "department_id"
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "publicly_viewable"
  end

  create_table "line_items", :force => true do |t|
    t.integer  "shift_report_id"
    t.boolean  "can_edit"
    t.datetime "time"
    t.text     "line_content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "location_groups", :force => true do |t|
    t.integer  "department_id"
    t.string   "long_name"
    t.string   "short_name"
    t.text     "description"
    t.string   "sub_email"
    t.string   "useful_links"
    t.float    "max_shift_length"
    t.float    "min_shift_length"
    t.integer  "perm_view_id"
    t.integer  "perm_signup_id"
    t.integer  "perm_admin_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "location_groups_restrictions", :id => false, :force => true do |t|
    t.integer "restriction_id",    :limit => 10, :default => 0, :null => false
    t.integer "location_group_id", :limit => 10, :default => 0, :null => false
  end

  create_table "locations", :force => true do |t|
    t.integer  "location_group_id"
    t.string   "long_name"
    t.string   "short_name"
    t.string   "report_email"
    t.string   "useful_links"
    t.integer  "max_staff"
    t.integer  "priority"
    t.integer  "min_staff"
    t.boolean  "active",            :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations_restrictions", :id => false, :force => true do |t|
    t.integer "restriction_id", :limit => 10, :default => 0, :null => false
    t.integer "location_id",    :limit => 10, :default => 0, :null => false
  end

  create_table "mass_clocks", :force => true do |t|
    t.string   "description"
    t.integer  "category_id"
    t.integer  "department_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notices", :force => true do |t|
    t.string   "type"
    t.string   "content",              :limit => 1000
    t.integer  "author_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "auth_users",           :limit => 1000, :default => ""
    t.string   "auth_locations",       :limit => 1000, :default => ""
    t.string   "auth_location_groups", :limit => 1000, :default => ""
    t.integer  "for_department_id"
    t.integer  "department_id"
    t.integer  "remover_id"
  end

  create_table "payform_configurations", :force => true do |t|
    t.integer  "department_id"
    t.integer  "payform_permission_id"
    t.integer  "payform_admin_permission_id"
    t.text     "printed",                     :limit => 5000
    t.text     "reminder",                    :limit => 5000
    t.boolean  "show_disabled_cats",                          :default => true
    t.text     "warning",                     :limit => 5000
    t.integer  "weeks"
    t.boolean  "clock",                                       :default => false
    t.integer  "description_min"
    t.integer  "reason_min"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payform_items", :force => true do |t|
    t.boolean  "active",                                                      :default => true
    t.boolean  "mass",                                                        :default => false
    t.decimal  "hours",                         :precision => 5, :scale => 2
    t.text     "description",   :limit => 1000
    t.date     "date"
    t.text     "reason",        :limit => 1000
    t.string   "added_by"
    t.integer  "category_id"
    t.integer  "department_id"
    t.integer  "mass_clock_id"
    t.integer  "mass_job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payform_items_payforms", :id => false, :force => true do |t|
    t.integer "payform_id",      :limit => 10, :default => 0, :null => false
    t.integer "payform_item_id", :limit => 10, :default => 0, :null => false
  end

  add_index "payform_items_payforms", ["payform_id"], :name => "payform_items_payforms_FKIndex2"
  add_index "payform_items_payforms", ["payform_item_id", "payform_id"], :name => "payform_items_payforms_FKIndex1", :unique => true

  create_table "payforms", :force => true do |t|
    t.integer  "week"
    t.integer  "year"
    t.datetime "submitted"
    t.datetime "approved"
    t.datetime "printed"
    t.integer  "approved_by"
    t.integer  "department_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permissions", :force => true do |t|
    t.string "name", :limit => 128, :default => "", :null => false
    t.text   "info"
  end

  create_table "permissions_roles", :id => false, :force => true do |t|
    t.integer "role_id",       :limit => 10, :default => 0, :null => false
    t.integer "permission_id", :limit => 10, :default => 0, :null => false
  end

  add_index "permissions_roles", ["permission_id", "role_id"], :name => "permissions_roles_FKIndex1", :unique => true
  add_index "permissions_roles", ["role_id"], :name => "permissions_roles_FKIndex2"

  create_table "preferences", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "show_bars",            :default => true
    t.string   "hide_location_groups"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "restrictions", :force => true do |t|
    t.integer  "max_subs"
    t.decimal  "hours_limit",       :precision => 5, :scale => 2
    t.datetime "starts"
    t.datetime "expires"
    t.integer  "location_id"
    t.integer  "location_group_id"
    t.integer  "for_department_id"
    t.integer  "department_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string "name",         :limit => 128, :default => "", :null => false
    t.string "display_name", :limit => 128, :default => "", :null => false
    t.text   "description"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "user_id", :limit => 10, :default => 0, :null => false
    t.integer "role_id", :limit => 10, :default => 0, :null => false
  end

  add_index "roles_users", ["role_id", "user_id"], :name => "roles_users_FKIndex1", :unique => true
  add_index "roles_users", ["user_id"], :name => "roles_users_FKIndex2"

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "shift_configurations", :force => true do |t|
    t.integer  "department_id"
    t.integer  "start"
    t.integer  "end"
    t.integer  "granularity"
    t.integer  "grace_period"
    t.boolean  "report_can_edit",                :default => false
    t.string   "useful_links"
    t.integer  "shift_permission_id"
    t.integer  "shift_admin_permission_id"
    t.integer  "department_admin_permission_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shift_reports", :force => true do |t|
    t.integer  "shift_id"
    t.datetime "start"
    t.datetime "end"
    t.string   "login_ip"
    t.string   "logout_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "payform_auto_added", :default => true
  end

  create_table "shifts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "location_id"
    t.datetime "start"
    t.datetime "end"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shifts", ["end"], :name => "index_shifts_on_end_time"
  add_index "shifts", ["start"], :name => "index_shifts_on_start_time"

  create_table "stats", :force => true do |t|
    t.datetime "start"
    t.datetime "stop"
    t.string   "user_ids"
    t.string   "location_ids"
    t.string   "location_group_ids"
    t.string   "department_ids"
    t.string   "view_by",            :default => "all"
    t.string   "group_by",           :default => "user"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subs", :force => true do |t|
    t.integer  "user_id"
    t.integer  "shift_id"
    t.datetime "bribe_start"
    t.datetime "bribe_end"
    t.datetime "start"
    t.datetime "end"
    t.integer  "new_shift"
    t.integer  "new_user"
    t.text     "reason"
    t.string   "target_ids"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "template_items", :force => true do |t|
    t.string   "type"
    t.integer  "start",       :default => 0
    t.integer  "end",         :default => 0
    t.integer  "wday"
    t.integer  "location_id"
    t.integer  "library_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "time_slots", :force => true do |t|
    t.integer  "location_id"
    t.datetime "start"
    t.datetime "end"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "time_slots", ["end"], :name => "index_slots_on_end_time"
  add_index "time_slots", ["start"], :name => "index_slots_on_start_time"

  create_table "users", :force => true do |t|
    t.string  "login",      :limit => 8,   :default => "",   :null => false
    t.string  "name",       :limit => 128
    t.boolean "active",                    :default => true, :null => false
    t.string  "first_name", :limit => 20
    t.string  "last_name",  :limit => 20
    t.string  "email",      :limit => 128
    t.integer "ein"
  end

end
