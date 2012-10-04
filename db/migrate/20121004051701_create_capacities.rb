class CreateCapacities < ActiveRecord::Migration
  def change
    create_table :capacities do |t|
      t.string :uuid
      t.string :name
      t.string :shortname

      t.timestamps
    end
  end
end
