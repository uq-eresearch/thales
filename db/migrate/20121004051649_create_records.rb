class CreateRecords < ActiveRecord::Migration
  def change
    create_table :records do |t|
      t.string :uuid

      t.integer :ser_type
      t.text :ser_data

      t.timestamps
    end
  end
end
