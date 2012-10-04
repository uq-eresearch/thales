class PropertySchema < ActiveRecord::Base
  belongs_to :schema
  belongs_to :property
  attr_accessible :order
end
