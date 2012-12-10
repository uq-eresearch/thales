# Copyright (c) 2012, The University of Queensland. (ITEE eResearch Lab)

# Ruby on Rails model.
#
# Represents roles the deployment suppports. This allows different
# deployments to define and customize their own user roles.

class Role < ActiveRecord::Base
  attr_accessible :name, :shortname, :uuid

  has_and_belongs_to_many :users
end
