class CreateLineItems < ActiveRecord::Migration
  def self.up
    create_table :line_items do |t|
      t.references :shift_report

      t.boolean :can_edit
      t.datetime :time
      t.text :line_content

      t.timestamps
    end
  end

  def self.down
    drop_table :line_items
  end
end
