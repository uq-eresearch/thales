# OAI Format for RIF-CS.
#
# Copyright (c) 2012, The University of Queensland. (ITEE eResearch Lab)

#----------------------------------------------------------------

module Thales
  module Output
    module OAIPMH

      class RifcsFormat < OAI::Provider::Metadata::Format

        RIF_NS = 'http://ands.org.au/standards/rif-cs/registryObjects'
        RIF_XSD = 'http://services.ands.org.au' +
          '/documentation/rifcs/schema/registryObjects.xsd'

        def initialize
          @prefix = 'rif'
          @schema = RIF_XSD
          @namespace = RIF_NS
          @element_namespace = 'rif'
          @fields = [ ] # not used, Record class has a to_rif method
        end

      end

    end
  end
end
