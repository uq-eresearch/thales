# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'thales/authentication/password'

# Create an initial set of roles and the root user.

role_sysadmin =
  Role.create(:name => 'System administrator',
              :shortname => 'sysadmin',
              :uuid => 'urn:uuid:0069d426-9753-4fa1-bdd0-7c39f5a54899')

Role.create(:name => 'System curator',
            :shortname => 'curator',
            :uuid => 'urn:uuid:778790da-00fb-4d32-8b99-0c4081a20f41')

Role.create(:name => 'General user',
            :shortname => 'user',
            :uuid => 'urn:uuid:f6e22756-6ebb-46bc-8746-cea5a17903d4')

user_root =
  User.create(:givenname => 'root',
              :surname => '',
              :uuid => 'urn:uuid:0e2d69c3-e840-4b7a-9100-548f97247ab5',
              :auth_type => Thales::Authentication::Password::AUTH_TYPE,
              :auth_name => 'root',
              :auth_value => nil) # nil means can login without password

user_root.roles << role_sysadmin
user_root.save

#EOF
