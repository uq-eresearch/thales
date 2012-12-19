#!/bin/env ruby
#
# A record is made up of zero or more properties. There are two
# kinds of properties: text properties and link properties.
#
# Copyright (c) 2012, The University of Queensland. (ITEE eResearch Lab)

require 'nokogiri'

require_relative 'property_text'
require_relative 'property_link'
require_relative 'profile'

module Thales
  module Datamodel
    module Cornerstone

      # Represents a generic record.
      #
      # This generic data model defines a record as an unordered set
      # of properties.  Each property consists of a global identifier
      # and an ordered sequence of one or more values. Only two types
      # of values are allowed: text and link.  Text values are simply
      # strings. Link values consist of a single mandatory URI and an
      # optional display string.

      class Record

        # XML namespace for representing instances of the
        # _Cornerstone_ data model.

        CONTAINER_NS = 'http://ns.research.data.uq.edu.au/2012/cornerstone'

        def initialize
          @properties = {}
        end

        def parse_form_parameters(profile, attr)
          if ! attr.nil?
            profile.each do |symbol, info|
              param = attr[symbol.to_s]

              if param
                if ! param.respond_to? :each
                  # Single value
                  if (param && param =~ /\S/)
                    init_one(info, param)
                  end

                else
                  # param contains { '1'=>,'10'=>,'11'=>,'2'=>,'3'=> ... }
                  param.keys.sort_by(&:to_i).map {
                    |key| param[key] # replace sorted keys with the values
                  }.select {
                    |str| (str && str =~ /\S/) # keep non-blank
                  }.each do |p|
                    init_one(info, p) # populate
                  end
                end
              end # if ! param.nil?

            end
          end
        end

        private
        def init_one(info, str)
          s = str.lstrip
          s.rstrip!
          s.gsub!(/\s+/, ' ')

          if ! info[:is_link]
            property_append(info[:gid], PropertyText.new(s))
          else
            i = s.index(' ')
            if i.nil?
              # Use text as URI and there is no hint
              uri = s
              hint = nil
            else
              # Use text before space as URI and text after as the hint
              uri = s.slice(0, i)
              hint = s.slice(i + 1, s.size - i - 1)
            end
            property_append(info[:gid], PropertyLink.new(uri, hint))
          end
        end

        # Appends a value to a property. If the property did not have
        # any values, the new value is set as the first value of the
        # property.
        #
        # ==== Parameters
        #
        # +global_id+:: global identifier of the property
        # +value+:: the value to append
        
        public
        def property_append(global_id, value)
          if @properties[global_id].nil?
            @properties[global_id] = []
          end
          @properties[global_id] << value
        end

        # Tests if a property has values.
        #
        # ==== Parameters
        #
        # +global_id+:: global identifier of the property
        #
        # ==== Returns
        #
        # True if the identified property has one or more values. False otherwise.
        
        def property_populated?(global_id)
          p = @properties[global_id]
          return ((! p.nil?) && (! p.empty?))
        end

        # Retrieves the values of a property.
        #
        # ==== Returns
        #
        # An Array containing all the values of the property with the
        # given global identifier.  If the property is not set
        # (i.e. does not have any values) an empty Array is returned.

        def property_get(global_id)
          if @properties[global_id].nil?
            @properties[global_id] = []
          end
          return @properties[global_id]
        end

        # Calls _block_ once for each property.
        #
        # The _block_ is called with the global identifier for the
        # property and an array of its values.

        def property_all
          @properties.keys.sort.each do |global_type|
            values = @properties[global_type]
            if ! values.empty?
              yield global_type, values
            end
          end
        end

        # Returns the number or properties in the instance of the data model.
        # Note: properties without any values are not counted.
        
        def size
          count = 0
          @properties.each do |gid, values|
            if ! values.empty?
              count += 1
            end
          end
          return count
        end

        # Compare two instances of the _Cornerstone_ data model.

        def ==(other)
          if self.size != other.size
            return false # not same set of properties
          end
          other.property_all do |gtype, other_values|
            if @properties[gtype] != other_values
              return false # property values are not equal
            end
          end
          return true
        end

        def serialize
          Nokogiri::XML::Builder.new { |xml| serialize_xml(xml) }.to_xml
        end

        def serialize_xml(xml)

          xml.data('xmlns' => CONTAINER_NS) {

            @properties.keys.sort.each do |global_type|
              @properties[global_type].each do |value|

                # TODO: should use the profile to determine text or link

                if value.is_a? PropertyText
                  xml.prop(value,
                           :type => global_type)
                elsif value.is_a? PropertyLink
                  xml.link(value.hint,
                           :type => global_type, :uri => value.uri)
                else
                  raise "Internal error: unsupported property value: class is #{value.class.to_s}"
                end
              end
            end
          }
        end

        # Populate a record from XML. Normally this method is called
        # on a newly created record, which won't have any pre-existing
        # properties set.
        #
        # ==== Parameters
        #
        # +str_or+node:: string containing XML or a Nokogiri node
        #
        # ==== Returns
        #
        # The record object with properties set from the XML. The
        # properties are appended to any existing properties already
        # set on the record.

        def deserialize(str_or_node)

          ns_defs = { 'c' => CONTAINER_NS }

          if str_or_node.respond_to? :xpath
            node = str_or_node
          else
            doc = Nokogiri::XML(str_or_node)
            node = doc.root
          end

          ns = node.namespace
          if ((node.name != 'record' && node.name != 'data') || # TODO: remove record
              ns.nil? || ns.href != CONTAINER_NS)
            n = ns.nil? ? '' : "{#{ns.href}}"
            raise "unexpected element: #{n}#{node.name}"
          end

          # Parse text properties
          node.xpath('c:prop', ns_defs).each do |element|
            property_append(element.attribute('type').content,
                            PropertyText.new(element.inner_text))
          end

          # Parse links
          node.xpath('c:link', ns_defs).each do |element|
            property_append(element.attribute('type').content,
                            PropertyLink.new(element.attribute('uri').content,
                                             element.inner_text))
          end

          return self
        end

      end # class Record
    end
  end
end

#EOF
