class Role < ActiveRecord::Base
  attr_accessible :name, :shortname, :uuid

  has_and_belongs_to_many :users
end
