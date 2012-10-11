class Record < ActiveRecord::Base
  attr_accessible :uuid

  has_many :entries
end
