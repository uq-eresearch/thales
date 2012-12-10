# Copyright (c) 2012, The University of Queensland. (ITEE eResearch Lab)

# Ruby on Rails model.

class Property < ActiveRecord::Base
  attr_accessible :description, :name, :shortname, :uuid
end
