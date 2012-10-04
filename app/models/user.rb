class User < ActiveRecord::Base
  attr_accessible :givenname, :surname, :uuid
end
