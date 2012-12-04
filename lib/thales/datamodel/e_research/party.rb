#!/bin/env ruby
#
# Copyright (C) 2012, The University of Queensland. (ITEE eResearch Lab)

basedir = File.expand_path(File.dirname(__FILE__))
require "#{basedir}/base"

module Thales
  module Datamodel
    class EResearch

      class Party < Thales::Datamodel::Cornerstone::Record

        @@profile = {

          :name_prefix => {
            label: 'Name prefix',
            singular: true,
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/name_prefix"
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

          creatorFor: {
            label: 'Data created',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/party/creatorFor",
            is_link: true,
          },
          
          managerFor: {
            label: 'Data managed',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/party/managerFor",
            is_link: true,
          },
          
          operatorFor: {
            label: 'Operates service',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/party/operatorFor",
            is_link: true,
          },
          
          participantIn: {
            label: 'Participates in activity',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/party/participantIn",
            is_link: true,
          },

          authorOf: {
            label: 'Author in publication',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/party/authorOf",
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

      end # class Party

    end # class EReserach
  end
end


#EOF
