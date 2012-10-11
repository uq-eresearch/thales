# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Property.create(:name => 'Editable collection',
                :shortname => 'Edit',
                :description => 'Internal format for an editable collection records',
                :uuid => 'd4cdb36b73a94b5295ac93232d5ce7b1')

Property.create(:name => 'Registry Interchange Format - Collections and Services',
                :shortname => 'RIF-CS',
                :description => 'RIF-CS XML format',
                :uuid => '70e8958d4f9245678c659a8fa0a9d1d0')

Property.create(:name => 'Atom Representation of Research Data Context',
                :shortname => 'Atom-RDC',
                :description => 'RIF-CS XML format',
                :uuid => '01a88873772842099809696d4d6d7a28')
