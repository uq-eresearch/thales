class CreateOaipmhRecords < ActiveRecord::Migration
  def change
    create_table :oaipmh_records do |t|
      t.boolean :withdrawn
      t.references :record

      t.timestamps
    end
  end
end
