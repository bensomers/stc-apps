class CreateLocationGroups < ActiveRecord::Migration
  def self.up
    create_table :location_groups do |t|
      t.references :department
      t.string :long_name
      t.string :short_name
      t.text :description
      t.string :sub_email
      t.string :useful_links
      
      #these floats are number of hours
      t.float :max_shift_length
      t.float :min_shift_length

      t.integer :perm_view_id
      t.integer :perm_signup_id
      t.integer :perm_admin_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :location_groups
  end
end
