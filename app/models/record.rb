# Copyright (c) 2012, The University of Queensland. (ITEE eResearch Lab)

# Ruby on Rails model.

class Record < ActiveRecord::Base
  attr_accessible :uuid

  attr_accessible :ser_type
  attr_accessible :ser_data

end
