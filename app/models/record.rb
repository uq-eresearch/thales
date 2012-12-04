class Record < ActiveRecord::Base
  attr_accessible :uuid

  attr_accessible :ser_type
  attr_accessible :ser_data

  has_many :entries
end
