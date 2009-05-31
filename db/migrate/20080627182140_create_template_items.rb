class CreateTemplateItems < ActiveRecord::Migration
  def self.up
    create_table :template_items do |t|

      # common to Shift & Time
      t.string :type #special for STI
      t.integer :start, :default => 0
      t.integer :end, :default => 0
      t.integer :wday
      t.references :location
      t.references :library
      
      # for Shift
      t.references :user      
      
      
      t.timestamps
    end
  end

  def self.down
    drop_table :template_items
  end
end
