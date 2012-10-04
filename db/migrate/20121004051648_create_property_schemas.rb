class CreatePropertySchemas < ActiveRecord::Migration
  def change
    create_table :property_schemas do |t|
      t.references :schema
      t.integer :order
      t.references :property

      t.timestamps
    end
    add_index :property_schemas, :schema_id
    add_index :property_schemas, :property_id
  end
end
