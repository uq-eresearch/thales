class CreateRecordSchemas < ActiveRecord::Migration
  def change
    create_table :record_schemas do |t|
      t.references :record
      t.references :schema

      t.timestamps
    end
    add_index :record_schemas, :record_id
    add_index :record_schemas, :schema_id
  end
end
