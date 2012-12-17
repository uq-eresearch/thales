class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :oaipmh_repositoryName
      t.string :oaipmh_adminEmail
      t.string :rifcs_group
      t.string :rifcs_originatingSource

      t.integer :singletonGuard

      t.timestamps
    end

    # Index to ensure that there is only one row in the table.
    add_index(:settings, :singletonGuard, :unique => true)
  end
end
