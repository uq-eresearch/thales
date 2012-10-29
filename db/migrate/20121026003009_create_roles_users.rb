
# Join table for associating users with roles

class CreateRolesUsers < ActiveRecord::Migration
  def change
    create_table :roles_users, :id => false do |t|
      t.references :role
      t.references :user
    end
  end
end
