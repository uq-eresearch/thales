#!/bin/env ruby
#
# The eResearch module defines schemas for Cornerstone records for
# representing concepts from ISO 2146:2010 (Information and
# documentation - Registry services for libraries and related
# organizations). Namely, collections, parties, activities and
# services.
#
# Copyright (C) 2012, The University of Queensland. (ITEE eResearch Lab)

basedir = File.expand_path(File.dirname(__FILE__))
require "#{basedir}/base"

module Thales
  module Datamodel
    class EResearch

      class Collection < Thales::Datamodel::Cornerstone::Record

        TYPE = "#{TYPE_BASE_URI}/collection"

        @@profile = {
          # Coverage

          temporal: {
            label: 'Temporal coverage',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/temporal",
          },

          spatial: {
            label: 'Spatial coverage',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/spatial",
          },

          # Rights

          rights_access: {
            label: 'Access rights',
            singular: true,
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/Rights_access",
          },
          
          rights_statement: {
            label: 'Rights statement',
            singular: true,
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/rights_statement",
          },
          
          rights_licence: {
            label: 'Licence',
            singular: true,
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/rights_licence",
          },

          # Relationships

          createdBy: {
            label: 'Creator of data',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/collection/createdBy",
            is_link: true,
          },
          
          managedBy: {
            label: 'Manager of data',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/collection/managedBy",
            is_link: true,
          },
          
          accessedBy: {
            label: 'Service to access data',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/collection/accessedVia",
            is_link: true,
          },
          
          referencedBy: {
            label: 'Data referenced in publication',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/collection/referencedBy",
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

      end # class Collection

    end # class EReserach
  end
end

#EOF
