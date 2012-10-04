class CreateProperties < ActiveRecord::Migration
  def change
    create_table :properties do |t|
      t.string :uuid
      t.string :name
      t.string :shortname
      t.text :description

      t.timestamps
    end
  end
end
