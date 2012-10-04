class RecordSchema < ActiveRecord::Base
  belongs_to :record
  belongs_to :schema
  # attr_accessible :title, :body
end
