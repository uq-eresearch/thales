# Copyright (c) 2012, The University of Queensland. (ITEE eResearch Lab)

require 'securerandom'

require_relative 'ident'

# Ruby on Rails model.

class Record < ActiveRecord::Base
  attr_accessible :uuid

  attr_accessible :ser_type
  attr_accessible :ser_data

  has_many :idents, :dependent => :destroy

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

    old_set = {}
    self.idents.each do |ident|
      old_set[ident.identifier] = ident
    end

    new_set = {}
    data.identifier.each do |identifier|
      new_set[identifier.to_s] = true
    end

    new_set.each_key do |identifier|
      if ! old_set.has_key?(identifier)
        i = Ident.new
        i.identifier = identifier.to_s
        self.idents << i
      end
    end

    old_set.each_pair do |identifier, ident|
      if ! new_set.has_key?(identifier)
        self.idents.delete(ident)
      end
    end
    
  end

  # Finds records by identifiers inside their data
  #
  # ==== Parameters
  #
  # +identifier+:: identifier to match
  #
  # ==== Returns
  #
  # An array of zero or more records which contain the
  # identifier as one of its identifiers.

  def self.find_by_identifier(identifier)
    matches = Ident.where(identifier: identifier)
    return matches.uniq.map { |i| i.record }
  end
end
