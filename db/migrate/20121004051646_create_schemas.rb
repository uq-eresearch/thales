class CreateSchemas < ActiveRecord::Migration
  def change
    create_table :schemas do |t|
      t.string :uuid
      t.string :name
      t.string :shortname

      t.timestamps
    end
  end
end
