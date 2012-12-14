class CreateIdents < ActiveRecord::Migration
  def change
    create_table :idents do |t|
      t.references :record
      t.string :identifier

      t.timestamps
    end
    add_index :idents, :record_id
    add_index :idents, :identifier
  end
end
