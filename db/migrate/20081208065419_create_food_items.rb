class CreateFoodItems < ActiveRecord::Migration
  def self.up
    create_table :food_items do |t|
      t.string :name
      t.decimal :price, :precision => 3, :scale => 2, :null => false
      t.boolean :available, :default => true

      t.timestamps
    end
  end

  def self.down
    drop_table :food_items
  end
end
