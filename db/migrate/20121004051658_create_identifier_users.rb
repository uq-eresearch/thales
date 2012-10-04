class CreateIdentifierUsers < ActiveRecord::Migration
  def change
    create_table :identifier_users do |t|
      t.references :user
      t.references :authority
      t.string :value

      t.timestamps
    end
    add_index :identifier_users, :user_id
    add_index :identifier_users, :authority_id
  end
end
