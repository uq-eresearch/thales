#!/bin/env ruby
#
# Copyright (C) 2012, The University of Queensland. (ITEE eResearch Lab)

basedir = File.expand_path(File.dirname(__FILE__))
require "#{basedir}/base"

module Thales
  module Datamodel
    class EResearch

      class Service < Thales::Datamodel::Cornerstone::Record

        TYPE = "#{TYPE_BASE_URI}/service"

        @@profile = {

          # Relationships

          operatedBy: {
            label: 'Operator',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/collection/operatedBy",
            is_link: true,
          },
          
          providesAccessTo: {
            label: 'Data',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/collection/providesAccessTo",
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

      end # class Service

    end # class EReserach
  end
end

#EOF
