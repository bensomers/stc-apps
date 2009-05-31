class AddPubliclyViewableToLibrary < ActiveRecord::Migration
  def self.up
    add_column :libraries, :publicly_viewable, :boolean
  end

  def self.down
    remove_column :libraries, :publicly_viewable, :boolean
  end
end
