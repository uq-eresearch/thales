class CreatePropertyRecords < ActiveRecord::Migration
  def change
    create_table :property_records do |t|
      t.references :record
      t.references :property
      t.integer :order
      t.text :value

      t.timestamps
    end
    add_index :property_records, :record_id
    add_index :property_records, :property_id
  end
end
