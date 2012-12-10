#!/bin/env ruby
#
# Copyright (c) 2012, The University of Queensland. (ITEE eResearch Lab)

basedir = File.expand_path(File.dirname(__FILE__))
require "#{basedir}/base"

module Thales
  module Datamodel
    module EResearch

      # Represents an eResearch party record. The data model for
      # a eResearch party record is different from the datamodel
      # of a RIF-CS party record, even though it is quite similar.
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
      # * name_prefix
      # * name_given
      # * name_family
      # * creatorFor
      # * managerFor
      # * participantIn
      # * operatorFor
      # * authorOf

      class Party < Base

        TYPE = "#{TYPE_BASE_URI}/party"

        @@profile = {

          :name_prefix => {
            label: 'Name title',
            singular: true,
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/name_title"
          },
          :name_given => {
            label: 'Given name',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/name_given"
          },
          :name_family => {
            label: 'Family name',
            singular: true,
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/name_family"
          },

          # Relationships

          creatorFor: { # collection
            label: 'Data created',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/party/creatorFor",
            is_link: true,
          },
          
          managerFor: { # collection
            label: 'Data managed',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/party/managerFor",
            is_link: true,
          },
          
          participantIn: { # activity
            label: 'Participates in activity',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/party/participantIn",
            is_link: true,
          },

          operatorFor: { # service
            label: 'Operates service',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/party/operatorFor",
            is_link: true,
          },
          
          authorOf: { # publication
            label: 'Author in publication',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/party/authorOf",
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

          party_attrs = {}
          party_attrs[:type] = 'person'
          if date_modified
            party_attrs[:dateModified] = date_modified.iso8601
          end

          builder.party(party_attrs) {
            base_to_rifcs(builder)

            builder.name {
              name_prefix.each { |x| builder.namePart(x, type: 'title') }
              name_given.each { |x| builder.namePart(x, type: 'given') }
              name_family.each { |x| builder.namePart(x, type: 'family') }
            }

            related_object(creatorFor, :isOwnerOf, builder) # collection
            related_object(managerFor, :isManagerOf, builder) # collection
            related_object(participantIn, :isParticipantIn, builder) # activity
#            related_object(operatorFor, :foo, builder) # service
#            related_object(authorOf, :foo, builder) # publication
          }
        end

      end # class Party

    end # class EReserach
  end
end


#EOF
