#!/bin/env ruby
#
# Copyright (c) 2012, The University of Queensland. (ITEE eResearch Lab)

basedir = File.expand_path(File.dirname(__FILE__))
require "#{basedir}/base"

module Thales
  module Datamodel
    module EResearch

      # Represents an eResearch activity record. The data model for a
      # eResearch activity record is different from the datamodel of a
      # RIF-CS activity record, even though it is quite similar.
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
      # * temporal
      # * producerFor
      # * hasParticipant

      class Activity < Base

        TYPE = "#{TYPE_BASE_URI}/activity"

        @@profile = {
          # Coverage

          temporal: {
            label: 'Temporal coverage',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/temporal",
          },

          # Relationships

          producerFor: { # collection
            label: 'Data produced',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/activity/producerFor",
            is_link: true,
          },
          
          hasParticipant: { # party
            label: 'Participant',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/activity/hasParticipant",
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

          activity_attrs = {}
          activity_attrs[:type] = 'project'
          if date_modified
            activity_attrs[:dateModified] = date_modified.iso8601
          end

          builder.activity(activity_attrs) {
            base_to_rifcs(builder)
            temporal_to_rifcs(builder)
            related_object(producerFor, :hasOutput, builder) # collection
            related_object(hasParticipant, :hasParticipant, builder) # party
          }
        end

      end # class Activity

    end # class EReserach
  end
end

#EOF
