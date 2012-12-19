#!/bin/env ruby
#
# The eResearch module defines schemas for Cornerstone records for
# representing concepts from ISO 2146:2010 (Information and
# documentation - Registry services for libraries and related
# organizations). Namely, collections, parties, activities and
# services.
#
# Copyright (c) 2012, The University of Queensland. (ITEE eResearch Lab)

require_relative 'base'

module Thales
  module Datamodel
    module EResearch

      # Represents an eResearch collection record. The data model for
      # a eResearch collection record is different from the datamodel
      # of a RIF-CS collection record, even though it is quite similar.
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
      # * spatial_geoname
      # * spatial_point
      # * spatial_polygon
      # * rights_access
      # * rights_statement
      # * rights_licence
      # * createdBy
      # * managedBy
      # * producedBy
      # * accessedVia
      # * referencedBy
      # * isRelatedTo

      class Collection < Base

        # Constant used to indicate a collection record.

        TYPE = "#{TYPE_BASE_URI}/collection"

        @@profile = {
          # Coverage

          temporal: {
            label: 'Temporal coverage',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/temporal",
          },

          spatial_geoname: {
            label: 'Spatial (geoname)',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/spatial_geoname",
            is_link: true,
          },
          spatial_point: {
            label: 'Spatial (point)',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/spatial_point",
          },
          spatial_polygon: {
            label: 'Spatial (polygon)',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/spatial_polygon",
          },

          # Rights

          rights_access: {
            label: 'Access rights',
            textarea: true,
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/rights_access",
          },
          
          rights_statement: {
            label: 'Rights statement',
            singular: true,
            textarea: true,
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

          createdBy: { # party
            label: 'Creator of data',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/collection/createdBy",
            is_link: true,
          },
          
          managedBy: { # party
            label: 'Manager of data',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/collection/managedBy",
            is_link: true,
          },

          producedBy: { # activity
            label: 'Produced by',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/collection/producedBy",
            is_link: true,
          },
          
          accessedVia: { # service
            label: 'Service to access data',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/collection/accessedVia",
            is_link: true,
          },
          
          referencedBy: { # publication
            label: 'Data referenced in publication',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/collection/referencedBy",
            is_link: true,
          },

          isRelatedTo: { # collection
            label: 'Related data collection',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/collection/isRelatedTo",
            is_link: true,
          },

        }.merge!(Thales::Datamodel::EResearch::Base::COMMON_PROFILE_ITEMS)

        # Returns the profile for collection records.

        def self.profile
          return @@profile
        end

        @@profile.each do |symbol, options|
          global_id = options[:gid]
          define_method(symbol) {
            property_get(global_id)
          }
        end

        # Creates a new +Collection+ object.
        #
        # ==== Parameters
        #
        # +attr+:: Ruby on Rails form parameters.

        def initialize(attr = nil)
          super()
          parse_form_parameters(@@profile, attr)
        end

        # Represents the collection record as RIF-CS.
        #
        # ==== Parameters
        # +builder+:: Nokogiri XML builder object.
        # +date_modified+:: optional date for the +dateModified+ attribute on the +collection+ element.
        #
        # ==== Returns
        #
        # Nokogiri builder object.
        #
        # ==== Example
        #
        #   c = Thales::Datamodel::EResearch::Collection.new(attr)
        #   b = Nokogiri::XML::Builder.new do |xml|
        #    c.to_rifcs(xml)
        #   end
        #   puts b.to_xml

        def to_rifcs(builder, date_modified = nil)

          collection_attrs = { 'xmlns' => RIFCS_NS }
          collection_attrs[:type] = rifcs_subtype()
          if date_modified
            collection_attrs[:dateModified] = date_modified.iso8601
          end

          builder.collection(collection_attrs) {
            base_to_rifcs(builder)
            temporal_to_rifcs(builder)
            spatial_to_rifcs(builder)

            if ! (rights_access.empty? &&
                  rights_statement.empty? &&
                  rights_licence.empty?)
              builder.rights {
                if ! rights_statement.empty? 
                  # rightsUri: optional attribute
                  builder.rightsStatement(rights_statement[0])
                end
                if ! rights_licence.empty? 
                  # type: rightsUri:
                  builder.licence(rights_licence[0])
                end
                if ! rights_access.empty? 
                  # type: rightsUri:
                  builder.accessRights(rights_access[0])
                end
              }
            end

            related_object(createdBy, :hasCollector, builder) # party
            related_object(managedBy, :isManagedBy, builder) # party
            related_object(producedBy, :isOutputOf, builder) # activity
            related_object(accessedVia, :supports, builder) # service
            related_object(isRelatedTo, :hasAssociationWith, builder) # collection
            related_info(referencedBy, builder) # publication
          }
        end

        # Represents the spatial coverage properties in RIF-CS.
        #
        # ==== Parameters
        #
        # +builder+:: Nokogiri XML builder object.

        private
        def spatial_to_rifcs(builder)
          spatial_geoname.each do |x|
            builder.location {
              builder.spatial("name=#{x.hint}", type: 'dcmiPoint') # TODO: include coordinates
            }
          end
          spatial_point.each do |x|
            if x =~ /^\s*([+-]?\d+(\.\d+)?)\,([+-]?\d+(\.\d+)?)\s*$/
              builder.location {
                builder.spatial("east=#{$1}; north=#{$3}", type: 'dcmiPoint')
              }
            end
          end
          spatial_polygon.each do |x|
            builder.location {
              builder.spatial(x, type: 'kmlPolyCoords')
            }
          end
        end

      end # class Collection

    end # class EReserach
  end
end

#EOF
