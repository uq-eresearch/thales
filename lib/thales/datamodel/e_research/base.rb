#!/bin/env ruby
#
# Copyright (c) 2012, The University of Queensland. (ITEE eResearch Lab)

require 'uri'
require_relative '../cornerstone'

module Thales
  module Datamodel
    module EResearch

      # All Collection, Party, Activity and Service record have the following
      # common convenience methods:
      #
      # * subtype
      # * identifier
      # * title
      # * title_alt
      # * description
      # * tag_keyword
      # * tag_FoR
      # * tag_SEO
      # * contact_email
      # * web_page

      class Base < Thales::Datamodel::Cornerstone::Record

        # Default maximum length for property values

        DEFAULT_MAXLENGTH = 255

        # Base URI for the +TYPE+ constants

        TYPE_BASE_URI = 'http://ns.research.data.uq.edu.au/2012/eResearch/type'

        # Base URI for the subtypes

        SUBTYPE_BASE_URI = 'http://ns.research.data.uq.edu.au/2012/eResearch/subtype'

        # Base URI for the property global identifiers

        PROPERTY_BASE_URI = 'http://ns.research.data.uq.edu.au/2012/eResearch/property'

        # Profile definitions that are merged into the Collection,
        # Party, Activity and Service profiles.

        COMMON_PROFILE_ITEMS = {
          
          :subtype => {
            label: 'Subtype',
            singular: true,
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/subtype"
          },

          :identifier => {
            label: 'Identifier',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/identifier"
          },

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
            textarea: true,
            maxlength: 2000, # TODO
            gid: "#{PROPERTY_BASE_URI}/description"
          },

          # Tags

          :tag_keyword => {
            label: 'Keyword',
            maxlength: 32,
            gid: "#{PROPERTY_BASE_URI}/tag_keyword",
          },

          :tag_FoR => {
            label: 'Field of Research (FoR)',
            maxlength: DEFAULT_MAXLENGTH, # fit URI plus hint
            gid: "#{PROPERTY_BASE_URI}/tag_FoR",
            is_link: true,
          },

          :tag_SEO => {
            label: 'Socio-Economic Outcomes (SEO)',
            maxlength: DEFAULT_MAXLENGTH, # fit URI plus hint
            gid: "#{PROPERTY_BASE_URI}/tag_SEO",
            is_link: true,
          },

          # Other

          :contact_email => {
            label: 'Contact email',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/contact_email",
          },

          :web_page => {
            label: 'Web page',
            maxlength: DEFAULT_MAXLENGTH,
            gid: "#{PROPERTY_BASE_URI}/web_page",
          },
        }

        # Returns a string that can be used as a title for the record.
        #
        # ==== Returns
        #
        # This will be derived from the given and family names for a person,
        # or be the primary title for everything else.

        def display_title

          if (subtype &&
              subtype[0] &&
              subtype[0] == "#{SUBTYPE_BASE_URI}/party/person")
            # People have names
            str = nil

            g = name_given
            if g && ! g.empty?
              str = g[0]
            end

            f = name_family
            if f && ! f.empty?
              if str
                str += " #{f[0]}"
              else
                str = f[0]
              end
            end

            if str
              return str
            end

          else
            # All others have titles

            t = title
            if t
              t = title[0]
              if t
                if t && ! t.blank?
                  return t
                end
              end
            end
          end

          return '(untitled)'
        end

        # Derive the type attribute value for a RIF-CS identifier.

        private
        def identifier_type(id)
          id_type = 'local' # until proven otherwise

          if (id =~ %r{^http://nla\.gov\.au/nla\.party-\d+$} || 
              id =~ %r{^nla\.party-\d+$})
            id_type = 'AU-ANL:PEAU'
          else
            begin
              uri = URI::parse(id)
              if uri.absolute? &&
                  (id.starts_with?('http://') ||
                   id.starts_with?('https://') ||
                   id.starts_with?('ftp:') ||
                   id.starts_with?('mailto:'))
                id_type = 'uri' # until a specific type of URI is identified

                if id.starts_with?('http://purl.org/')
                  id_type = 'purl'
                elsif id.starts_with?('http://dx.doi.org/')
                  id_type = 'doi'
                elsif id.starts_with?('http://orcid.org/')
                  id_type = 'ORCID'
                end
              end
            rescue URI::InvalidURIError
              # Not a URI
            end
          end

          return id_type
        end

        RIFCS_NS = 'http://ands.org.au/standards/rif-cs/registryObjects'

        # Represents the base properties as RIF-CS.
        #
        # This method is used by the subclasses in their +to_rifcs+
        # methods.
        #
        # ==== Parameters
        #
        # +builder+:: Nokogiri XML builder

        protected
        def base_to_rifcs(builder)

          identifier.each do |x|
            builder.identifier(x, type: identifier_type(x))
          end

          if (subtype &&
              subtype[0] &&
              subtype[0] == "#{SUBTYPE_BASE_URI}/party/person")
            # People have name components
            builder.name(type: 'primary') {
              name_prefix.each { |x| builder.namePart(x, type: 'title') }
              name_given.each { |x| builder.namePart(x, type: 'given') }
              name_family.each { |x| builder.namePart(x, type: 'family') }
            }
          else
            # All others have titles and alternative titles
            title.each { |x|
              builder.name(type: 'primary') {
                builder.namePart(x)
              }
            }
            title_alt.each { |x|
              builder.name(type: 'alternative') {
                builder.namePart(x)
              }
            }
          end

          description.each { |x| builder.description(x, type: 'full') }

          tag_keyword.each { |x| builder.subject(x, type: 'local') }
          tag_FoR_to_rifcs(builder)
          tag_SEO_to_rifcs(builder)

          contact_email.each { |x|
            builder.location {
              builder.address {
                builder.electronic(type: 'email') {
                  builder.value(x)
                }
              }
            }
          }
          web_page.each { |x|
            builder.location {
              builder.address {
                builder.electronic(type: 'url') {
                  builder.value(x)
                }
              }
            }
          }
        end

        FOR_URI_PREFIX = 'http://purl.org/asc/1297.0/2008/for/'

        def tag_FoR_to_rifcs(builder)
          tag_FoR.each do |x|
            uri = x.uri
            if uri.start_with?(FOR_URI_PREFIX)
              rest = uri[FOR_URI_PREFIX.length..-1]
              if rest =~ /^(\d+)$/
                builder.subject($~[1], type: 'anzsrc-for')
              end
            end
          end
        end

        SEO_URI_PREFIX = 'http://purl.org/asc/1297.0/2008/seo/'

        def tag_SEO_to_rifcs(builder)
          tag_SEO.each do |x|
            uri = x.uri
            if uri.start_with?(SEO_URI_PREFIX)
              rest = uri[SEO_URI_PREFIX.length..-1]
              if rest =~ /^(\d+)$/
                builder.subject($~[1], type: 'anzsrc-seo')
              end
            end
          end
        end

        # Mapping from internal subtype URI values to RIF-CS type values.
        # Default is set.

        RIFCS_SUBTYPE = {
          "#{SUBTYPE_BASE_URI}/collection/collection" => 'collection',
          "#{SUBTYPE_BASE_URI}/collection/dataset" => 'dataset',

          "#{SUBTYPE_BASE_URI}/party/person" => 'person',
          "#{SUBTYPE_BASE_URI}/party/group" => 'group',
          "#{SUBTYPE_BASE_URI}/party/position" => 'administrativePosition',

          "#{SUBTYPE_BASE_URI}/activity/project" => 'project',
          "#{SUBTYPE_BASE_URI}/activity/program" => 'program',

          "#{SUBTYPE_BASE_URI}/service/report" => 'report',
        }
        RIFCS_SUBTYPE.default = 'UNKNOWN_SUBTYPE'

        # Maps internal subtypes into values for the RIF-CS "type"
        # attribute on the collection/party/activity/service element.

        def rifcs_subtype
          subtype ? RIFCS_SUBTYPE[subtype[0]] : RIFCS_SUBTYPE.default
        end

        # Represents the temporal properties as RIF-CS.
        #
        # This method is used by the Collection and Activity
        # subclasses in their +to_rifcs+ methods, since those
        # two subclasses have +temporal+ properties.
        #
        # ==== Parameters
        #
        # +builder+:: Nokogiri XML builder

        def temporal_to_rifcs(builder)
          temporal.each do |x|

            builder.coverage {
              builder.temporal {
                
                if (x =~ /^(\d{4})$/ ||
                    x =~ /^(\d{4}-\d{2})$/ ||
                    x =~ /^(\d{4}-\d{2}-\d{2})$/)
                  # Single date (TODO: is having two date elements correct?)
                  builder.date($~[1], type: 'dateFrom', dateFormat: 'W3CDTF')
                  builder.date($~[1], type: 'dateTo', dateFormat: 'W3CDTF')

                elsif (x =~ /^(\d{4})\/(\d{4})$/ ||
                       x =~ /^(\d{4}-\d{2})\/(\d{4}-\d{2})$/ ||
                       x =~ /^(\d{4}-\d{2}-\d{2})\/(\d{4}-\d{2}-\d{2})$/)
                  # Date range
                  builder.date($~[1], type: 'dateFrom', dateFormat: 'W3CDTF')
                  builder.date($~[2], type: 'dateTo', dateFormat: 'W3CDTF')

                else
                  # Unrecognised temporal value, treat as text
                  builder.text_(x)
                end
              } # </temporal>
            } # </coverage>
          end

        end

        # Generates RIF-CS relatedObject element from an array of
        # Thales::Datamodel::Cornerstone::PropertyLink objects.
        #
        # This method is used by the subclasses in their +to_rifcs+
        # methods.
        #
        # ==== Parameters
        #
        # +values+:: array of PropertyLink objects
        # +type+:: string value to use for the RIF-CS <tt>relatedObject/relation/@type</tt> attribute
        # +builder+:: Nokogiri XML builder

        protected
        def related_object(values, type, builder)
          values.each do |value|

            targets = Record.find_by_identifier(value.uri)

            if ! targets.empty?
              # Object(s) exists in this feed: represent as a relatedObject(s)
              targets.each do |target|
                builder.relatedObject {
                  builder.key(target.uuid)
                  builder.relation(type: type)
                }
              end
            else
              # Object does not exist in this feed: represent as relatedInfo
              builder.relatedInfo {
                builder.identifier(value.uri, type: 'uri')
                if value.hint && ! value.hint.blank?
                  builder.title(value.hint)
                end
                builder.notes(type)
              }
            end

          end
        end

        # Generates RIF-CS relatedInfo element from an array of
        # Thales::Datamodel::Cornerstone::PropertyLink objects.
        #
        # This method is used by the subclasses in their +to_rifcs+
        # methods.
        #
        # ==== Parameters
        #
        # +values+:: array of PropertyLink objects
        # +type+:: string value to use for the RIF-CS <tt>relatedInfo/relation/@type</tt> attribute
        # +builder+:: Nokogiri XML builder

        protected
        def related_info(values, builder)
          values.each do |value|
            builder.relatedInfo {
              builder.identifier(value.uri, type: 'uri')
              if value.hint && ! value.hint.blank?
                builder.title(value.hint)
              end
            }
          end
        end

      end

    end # class EReserach
  end
end

#EOF
