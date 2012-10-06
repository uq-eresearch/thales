class Record < ActiveRecord::Base
  attr_accessible :uuid

  has_many :property_records
end
