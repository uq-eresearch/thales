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
require "#{basedir}/cornerstone"

module Thales
  module Datamodel
    class EResearch

      DEFAULT_MAXLENGTH = 255
      PROPERTY_BASE_URI = 'http://ns.research.data.uq.edu.au/2012/eResearch/property'

      class Common < Thales::Datamodel::Cornerstone::Record

        group "Data content" do
          text_property :title, 'Title',
          singular: true,
          maxlength: DEFAULT_MAXLENGTH,
          type: "#{PROPERTY_BASE_URI}/title"

          text_property :title_alt, 'Alternative title',
          maxlength: DEFAULT_MAXLENGTH,
          type: "#{PROPERTY_BASE_URI}/title_alt"

          text_property :description, 'Description',
          singular: true,
          maxlength: 2000,
          type: "#{PROPERTY_BASE_URI}/description"

          text_property :identifier, 'Identifier',
          maxlength: DEFAULT_MAXLENGTH,
          type: "#{PROPERTY_BASE_URI}/identifier"
        end

        group "Topics" do
          text_property :tag_keyword, 'Keyword',
          maxlength: 32,
          type: "#{PROPERTY_BASE_URI}/Keyword"
          
          text_property :tag_FoR, 'Field of Research (FoR)',
          maxlength: 8,
          type: "#{PROPERTY_BASE_URI}/tag_for"
          
          text_property :tag_SEO, 'Socio-Economic Outcomes (SEO)',
          maxlength: 8,
          type: "#{PROPERTY_BASE_URI}/tag_SEO"
        end

        group "Other" do
          text_property :contact_email, 'Contact email',
          maxlength: DEFAULT_MAXLENGTH,
          type: "#{PROPERTY_BASE_URI}/email"
          
          text_property :web_page, 'Web page',
          maxlength: DEFAULT_MAXLENGTH,
          type: "#{PROPERTY_BASE_URI}/web_page"
        end

      end

      class Collection < Common

        group "Coverage" do
          text_property :temporal, 'Temporal coverage',
          maxlength: DEFAULT_MAXLENGTH,
          type: "#{PROPERTY_BASE_URI}/temporal"

          text_property :spatial, 'Spatial coverage',
          maxlength: DEFAULT_MAXLENGTH,
          type: "#{PROPERTY_BASE_URI}/spatial"
        end

        group "Rights" do
          text_property :rights_access, 'Access rights',
          singular: true,
          maxlength: DEFAULT_MAXLENGTH,
          type: "#{PROPERTY_BASE_URI}/Rights_access"
          
          text_property :rights_statement, 'Rights statement',
          singular: true,
          maxlength: DEFAULT_MAXLENGTH,
          type: "#{PROPERTY_BASE_URI}/rights_statement"
          
          text_property :rights_licence, 'Licence',
          singular: true,
          maxlength: DEFAULT_MAXLENGTH,
          type: "#{PROPERTY_BASE_URI}/rights_licence"
        end

        group "Relationships" do
          link_property :createdBy, 'Creator of data',
          maxlength: DEFAULT_MAXLENGTH,
          type: "#{PROPERTY_BASE_URI}/collection/createdBy"
          
          link_property :managedBy, 'Manager of data',
          maxlength: DEFAULT_MAXLENGTH,
          type: "#{PROPERTY_BASE_URI}/collection/managedBy"
          
          link_property :accessedBy, 'Service to access data',
          maxlength: DEFAULT_MAXLENGTH,
          type: "#{PROPERTY_BASE_URI}/collection/accessedVia"
          
          link_property :referencedBy, 'Data referenced in publication',
          maxlength: DEFAULT_MAXLENGTH,
          type: "#{PROPERTY_BASE_URI}/collection/referencedBy"
        end

      end

    end # class EReserach
  end
end

#EOF
