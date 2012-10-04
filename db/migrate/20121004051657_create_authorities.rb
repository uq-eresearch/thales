class CreateAuthorities < ActiveRecord::Migration
  def change
    create_table :authorities do |t|
      t.string :uuid
      t.string :name
      t.string :shortname

      t.timestamps
    end
  end
end
