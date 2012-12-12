#
# Find a record based on identifiers
#
# Copyright (c) 2012, The University of Queensland. (ITEE eResearch Lab)
#----------------------------------------------------------------

#require 'record'

module Thales
  module Output
    module OAIPMH

      class Find
        def self.find_by_identifier(identifier)

          @records = Record.all.keep_if do |record|
            match = false
            r_class = Thales::Datamodel::CLASS_FOR[record.ser_type]
            data = r_class.new.deserialize(record.ser_data)
            data.identifier.each do |value|
              if value == identifier
                return record
                #match = true
                #break
              end
            end
            match
          end

          return nil
        end
      end

    end
  end
end
