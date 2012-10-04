class CreateRecordUsers < ActiveRecord::Migration
  def change
    create_table :record_users do |t|
      t.references :record
      t.references :capacity
      t.references :user

      t.timestamps
    end
    add_index :record_users, :record_id
    add_index :record_users, :capacity_id
    add_index :record_users, :user_id
  end
end
