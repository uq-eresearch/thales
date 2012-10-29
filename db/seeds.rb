# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'thales/authentication/password'

role_sysadmin =
  Role.create(:name => 'System administrator',
              :shortname => 'sysadmin',
              :uuid => '0069d42697534fa1bdd07c39f5a54899')

Role.create(:name => 'System curator',
            :shortname => 'curator',
            :uuid => '778790da00fb4d328b990c4081a20f41')

Role.create(:name => 'General user',
            :shortname => 'user',
            :uuid => 'f6e227566ebb46bc8746cea5a17903d4')

user_root =
  User.create(:givenname => '',
              :surname => 'root',
              :uuid => '0e2d69c3e8404b7a9100548f97247ab5',
              :auth_type => Thales::Authentication::Password::AUTH_TYPE,
              :auth_name => 'root',
              :auth_value => nil)

user_root.roles << role_sysadmin
user_root.save

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
