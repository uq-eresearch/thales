#!/bin/env ruby
#
# Copyright (C) 2012, The University of Queensland. (ITEE eResearch Lab)

module Thales
  module Datamodel
    module Cornerstone

      class PropertyLink
        attr_accessor :uri
        attr_accessor :hint

        def initialize(uri, display_hint = nil)
          @uri = uri
          @hint = display_hint
        end

        def ==(other)
          other.uri == uri && other.hint == hint
        end

        def to_s
          @hint ? "#{@uri} #{@hint}" : uri
        end
      end

    end
  end
end

#EOF
