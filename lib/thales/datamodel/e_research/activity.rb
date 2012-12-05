#!/bin/env ruby
#
# Copyright (C) 2012, The University of Queensland. (ITEE eResearch Lab)

basedir = File.expand_path(File.dirname(__FILE__))
require "#{basedir}/base"

module Thales
  module Datamodel
    class EResearch

      class Activity < Thales::Datamodel::Cornerstone::Record

        TYPE = "#{TYPE_BASE_URI}/activity"

        @@profile = {
          # Coverage

          temporal: {
            label: 'Temporal coverage',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/temporal",
          },

          # Relationships

          producerFor: {
            label: 'Data produced',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/collection/producerFor",
            is_link: true,
          },
          
          hasParticipant: {
            label: 'Participant',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/collection/hasParticipant",
            is_link: true,
          },
          
        }.merge!(Thales::Datamodel::EResearch::BASE_PROFILE)

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

      end # class Activity

    end # class EReserach
  end
end

#EOF
