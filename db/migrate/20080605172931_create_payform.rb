class CreatePayform < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.column "name",          :string
      t.column "active",        :boolean, :default => true
      t.column "department_id", :integer
      t.timestamps
    end
    
    create_table :edit_items do |t|
      t.column "hours",           :decimal, :precision => 5, :scale => 2
      t.column "description",     :text, :limit => 1000
      t.column "date",            :date
      t.column "reason",          :text, :limit => 1000 #reason for edit
      t.column "category_id",     :integer
      t.column "payform_item_id", :integer
      t.column "edited_by",       :string
      t.timestamps
    end
    
    create_table :payform_items do |t|
      t.boolean "active",       :default => true
      t.boolean "mass",         :default => false
      t.decimal "hours",        :precision => 5, :scale => 2
      t.text    "description",  :limit => 1000
      t.date    "date"
      t.text    "reason",       :limit => 1000
      t.string  "added_by"
      t.integer "category_id"
      t.integer "department_id"
      t.integer "mass_clock_id"
      t.integer "mass_job_id"
      t.timestamps
    end
    
    create_table :payforms do |t|
      t.column "week",          :integer
      t.column "year",          :integer
      t.column "submitted",     :datetime, :default => nil
      t.column "approved",      :datetime, :default => nil
      t.column "printed",       :datetime, :default => nil
      t.column "approved_by",   :integer
      t.column "department_id", :integer
      t.column "user_id",       :integer
      t.timestamps
    end
    
    create_table "payform_items_payforms", :id => false, :force => true do |t|
      t.column "payform_id",        :integer, :limit => 10, :default => 0, :null => false
      t.column "payform_item_id",   :integer, :limit => 10, :default => 0, :null => false
    end
    
    add_index "payform_items_payforms", ["payform_item_id","payform_id"], :name => "payform_items_payforms_FKIndex1", :unique => true
    add_index "payform_items_payforms", ["payform_id"], :name => "payform_items_payforms_FKIndex2", :unique => false

    create_table :payform_configurations do |t|
      t.column "department_id",               :integer
      t.column "payform_permission_id",       :integer
      t.column "payform_admin_permission_id", :integer
      t.column "printed",                     :text, :limit => 5000
      t.column "reminder",                    :text, :limit => 5000
      t.column "show_disabled_cats",          :boolean, :default => true
      t.column "warning",                     :text, :limit => 5000
      t.column "weeks",                       :int
      t.column "clock",                       :boolean, :default => false
      t.column "description_min",             :int
      t.column "reason_min",                  :int
      t.timestamps
    end

  end

  def self.down
    drop_table :payform_configurations
    drop_table :payforms
    drop_table :payform_items
    drop_table :edit_items
    drop_table :categories
  end
end
