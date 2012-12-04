#!/bin/env ruby
#
# The eResearch module defines schemas for Cornerstone records for
# representing concepts from ISO 2146:2010 (Information and
# documentation - Registry services for libraries and related
# organizations). Namely, collections, parties, activities and
# services.
#
# Copyright (C) 2012, The University of Queensland. (ITEE eResearch Lab)

#basedir = File.expand_path(File.dirname(__FILE__))
#require "#{basedir}/cornerstone"

module Thales
  module Datamodel
    class EResearch

      DEFAULT_MAXLENGTH = 255
      PROPERTY_BASE_URI = 'http://ns.research.data.uq.edu.au/2012/eResearch/property'

      BASE_PROFILE = {
          :title => {
            label: 'Title',
            singular: true,
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/title"
          },
          :title_alt => {
            label: 'Alternative title',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/title_alt"
          },
          :description => {
            label: 'Description',
            singular: true,
            maxlength: 2000, # TODO
            gid: "#{PROPERTY_BASE_URI}/description"
          },
          :identifier => {
            label: 'Identifier',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/identifier"
          },

          # Tags

          :tag_keyword => {
            label: 'Keyword',
            maxlength: 32,
            gid: "#{PROPERTY_BASE_URI}/Keyword",
          },

          :tag_FoR => {
            label: 'Field of Research (FoR)',
            maxlength: 8,
            gid: "#{PROPERTY_BASE_URI}/tag_for",
          },

          :tag_SEO => {
            label: 'Socio-Economic Outcomes (SEO)',
            maxlength: 8,
            gid: "#{PROPERTY_BASE_URI}/tag_SEO",
          },

          # Other

          :contact_email => {
            label: 'Contact email',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/email",
          },

          :web_page => {
            label: 'Web page',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/web_page",
          },
        }

#        def self.profile
#          return @@profile
#        end
#
#        @@profile.each do |symbol, options|
#          global_id = options[:gid]
#          define_method(symbol) {
#            property_get(global_id)
#          }
#        end
#
#        def initialize(attr = nil)
#          super()
#          parse_form_parameters(@@profile, attr)
#        end

    end # class EReserach
  end
end

#EOF
