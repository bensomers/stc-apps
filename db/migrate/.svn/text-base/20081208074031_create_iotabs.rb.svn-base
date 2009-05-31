class CreateIotabs < ActiveRecord::Migration
  def self.up
    create_table :iotabs do |t|
      t.integer :user_id
      t.integer :food_item_id
      t.integer :paid
      t.integer :unpaid

      t.timestamps
    end
  end

  def self.down
    drop_table :iotabs
  end
end
