# OAI-PMH sets.
#
# Copyright (c) 2012, The University of Queensland. (ITEE eResearch Lab)

#----------------------------------------------------------------

module Thales
  module Output
    module OAIPMH

      class Set < ActiveRecord::Base

        self.table_name = 'party_sets'

        attr_accessible :name, :notes, :prefix
        has_many :party_records
      end

    end
  end
end
