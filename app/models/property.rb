class Property < ActiveRecord::Base
  attr_accessible :description, :name, :shortname, :uuid
end
