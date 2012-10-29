class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :uuid
      t.string :surname
      t.string :givenname

      t.integer :auth_type
      t.string :auth_name
      t.string :auth_value

      t.timestamps
    end
  end
end
