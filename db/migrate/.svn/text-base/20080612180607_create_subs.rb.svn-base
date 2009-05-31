class CreateSubs < ActiveRecord::Migration
  def self.up
    create_table :subs do |t|
      t.references :user, :shift #this create shift_id (original shift) and user_id (user who request sub)
      
      t.datetime :bribe_start
      t.datetime :bribe_end
      t.datetime :start
      t.datetime :end
      t.integer :new_shift #id of the new shift created when sb takes a sub
      t.integer :new_user #id of the user who takes the sub
      t.text :reason
      t.string :target_ids #string of user_ids of those the sub requestor wanna offer the sub to

      t.timestamps
    end
  end

  def self.down
    drop_table :subs
  end
end
