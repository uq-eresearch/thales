class PropertyRecord < ActiveRecord::Base
  belongs_to :record
  belongs_to :property
  attr_accessible :order, :value
end
