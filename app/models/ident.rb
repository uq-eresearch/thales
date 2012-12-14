# Copyright (c) 2012, The University of Queensland. (ITEE eResearch Lab)

# Ruby on Rails model.

class Ident < ActiveRecord::Base
  belongs_to :record
  attr_accessible :identifier
end
