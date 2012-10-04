class IdentifierUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :authority
  attr_accessible :value
end
