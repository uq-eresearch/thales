class RecordUser < ActiveRecord::Base
  belongs_to :record
  belongs_to :capacity
  belongs_to :user
  # attr_accessible :title, :body
end
