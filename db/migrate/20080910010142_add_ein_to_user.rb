class AddEinToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :ein, :integer
  end

  def self.down
    remove_column :users, :ein
  end
end
