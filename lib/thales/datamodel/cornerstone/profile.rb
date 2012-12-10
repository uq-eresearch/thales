#!/bin/env ruby
#
# Copyright (c) 2012, The University of Queensland. (ITEE eResearch Lab)

#----------------------------------------------------------------

module Thales
  module Datamodel
    module Cornerstone
      class Profile

        attr_accessor :symbol_table

        def initialize
          @option = {}
          @groups = [] # array of (name, array of global_id) pairs
          @symbol_table = {}
        end

        def []=(global_id, options)
          if @option[global_id].nil?
            # New global_id, add to current group
            if ! @groups.empty?
              @groups.last[1] << global_id
            end
          end

          @option[global_id] = options
        end

        def [](global_id)
          return @option[global_id]
        end

        def all
          @option.keys.sort.each { |gid| yield gid }
        end

        def start_group(name)
          @groups << [ name, [] ]
        end

        def all_groups
          @groups.each do |g|
            yield g[0], g[1]
          end
        end

      end
    end
  end
end

#EOF
