class RoleUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :role
  # attr_accessible :title, :body
end
