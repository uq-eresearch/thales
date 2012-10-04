class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :uuid
      t.string :name
      t.string :shortname

      t.timestamps
    end
  end
end
