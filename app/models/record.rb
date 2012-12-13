# Copyright (c) 2012, The University of Queensland. (ITEE eResearch Lab)

require 'securerandom'

# Ruby on Rails model.

class Record < ActiveRecord::Base
  attr_accessible :uuid

  attr_accessible :ser_type
  attr_accessible :ser_data

  # Sets the uuid.
  #
  # ==== Parameters
  #
  # +value+:: the value to set the uuid to, or nil to set it to a newly generated one.

  def uuid_set(value = nil)
    self.uuid = value ? value : "urn:uuid:#{SecureRandom.uuid}"
  end

  # Set the data
  #
  # ==== Parameters
  #
  # +type+:: ser_type
  # +data+:: data to set it to Thales::Datamodel::EResearch::Base

  def data_set(type, data)
    self.ser_type = type
    self.ser_data = data.serialize
  end

  # Finds records by identifiers inside their data

  def self.find_by_identifier(identifier)

    matches = Record.all.keep_if do |record|
      match = false
      r_class = Thales::Datamodel::CLASS_FOR[record.ser_type]
      data = r_class.new.deserialize(record.ser_data)
      data.identifier.each do |value|
        if value == identifier
          match = true
          break
        end
      end
      match
    end
    return matches
    #return nil
  end
end
