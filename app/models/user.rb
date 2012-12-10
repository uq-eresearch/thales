# Copyright (c) 2012, The University of Queensland. (ITEE eResearch Lab)

# Ruby on Rails model.

class User < ActiveRecord::Base
  attr_accessible :givenname, :surname, :uuid
  attr_accessible :auth_type, :auth_name, :auth_value
  attr_accessible :auth_value_confirmation

  has_and_belongs_to_many :roles

  validates :surname, :presence => true
  validates :auth_name, :presence => true, :uniqueness => true
  validates_confirmation_of :auth_value, :message => 'Passwords do not match'
end
