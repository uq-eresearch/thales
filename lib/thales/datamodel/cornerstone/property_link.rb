#!/bin/env ruby
#
# Copyright (c) 2012, The University of Queensland. (ITEE eResearch Lab)

#----------------------------------------------------------------

module Thales
  module Datamodel
    module Cornerstone

      # Represents a link property in the Cornerstone data model.
      #
      # A link property consists of a mandatory URI and an optional
      # display hint.

      class PropertyLink
        attr_accessor :uri
        attr_accessor :hint

        # Create a new link property.
        #
        # ==== Parameters
        #
        # +uri+:: the URI value
        # +display_hint+:: optional text to display to the user

        def initialize(uri, display_hint = nil)
          @uri = uri
          @hint = display_hint
        end

        # Equality test for a link property

        def ==(other)
          other.uri == uri && other.hint == hint
        end

        # String representation of the link property.

        def to_s
          @hint ? "#{@uri} #{@hint}" : uri
        end
      end

    end
  end
end

#EOF
