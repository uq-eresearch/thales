#!/bin/env ruby
#
# Copyright (c) 2012, The University of Queensland. (ITEE eResearch Lab)

require_relative 'base'

module Thales
  module Datamodel
    module EResearch

      # Represents an eResearch service record. The data model for
      # a eResearch service record is different from the datamodel
      # of a RIF-CS service record, even though it is quite similar.
      #
      # == Convenience methods
      #
      # Since this is a subclass of the generic
      # Thales::Datamodel::Cornerstone::Record, its methods can be
      # used to access the properties.
      #
      # Convenience methods are available to access particular
      # values. The convenience methods are those defined in the
      # Thales::Datamodel::EResearch::Base class plus these:
      #
      # * operatedBy
      # * providesAccessTo

      class Service < Base

        TYPE = "#{TYPE_BASE_URI}/service"

        @@profile = {

          # Relationships

          operatedBy: { # party
            label: 'Operator',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/service/operatedBy",
            is_link: true,
          },
          
          providesAccessTo: { # collection
            label: 'Data',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/service/providesAccessTo",
            is_link: true,
          },

        }.merge!(Thales::Datamodel::EResearch::Base::COMMON_PROFILE_ITEMS)

        def self.profile
          return @@profile
        end

        @@profile.each do |symbol, options|
          global_id = options[:gid]
          define_method(symbol) {
            property_get(global_id)
          }
        end

        def initialize(attr = nil)
          super()
          parse_form_parameters(@@profile, attr)
        end

        def to_rifcs(builder, date_modified = nil)

          service_attrs = { 'xmlns' => RIFCS_NS }
          service_attrs[:type] = rifcs_subtype()
          if date_modified
            service_attrs[:dateModified] = date_modified.iso8601
          end

          builder.service(service_attrs) {
            base_to_rifcs(builder)
            related_object(operatedBy, :isManagedBy, builder) # party

            if (subtype &&
                subtype[0] &&
                subtype[0] == "#{SUBTYPE_BASE_URI}/service/report")
              rel = :presents
            else
              rel = :makesAvailable
            end
            related_object(providesAccessTo, rel, builder) # collection
          }
        end

      end # class Service

    end # class EReserach
  end
end

#EOF
