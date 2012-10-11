class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.references :record
      t.references :property
      t.integer :order
      t.text :value

      t.timestamps
    end
    add_index :entries, :record_id
    add_index :entries, :property_id
  end
end
