class CreateLibraries < ActiveRecord::Migration
  def self.up
    create_table :libraries do |t|
      
      t.string :type
      t.references :department

      t.string :name
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :libraries
  end
end
