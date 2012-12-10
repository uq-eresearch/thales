# Copyright (c) 2012, The University of Queensland. (ITEE eResearch Lab)

# Ruby on Rails model.

class Entry < ActiveRecord::Base
  belongs_to :record
  belongs_to :property
  attr_accessible :order, :value
end
