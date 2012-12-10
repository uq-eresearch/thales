# OAI Record.
#
# Record class.
#
# This class is passed to the OAI ActiveRecordWrapper class
# to use.
#
# Copyright (c) 2012, The University of Queensland. (ITEE eResearch Lab)
#----------------------------------------------------------------

require 'nokogiri'

#require 'partyTester/config'
require 'thales/output/oaipmh/set'
require 'thales/datamodel/e_research'

module Thales
  module Output
    module OAIPMH

      class Record < ActiveRecord::Base

        self.table_name = 'records'

        # attr_accessible :key
        # attr_accessible :surname
        # attr_accessible :forename
        # attr_accessible :testident
        # attr_accessible :description
        # attr_accessible :notes
        # attr_accessible :partySet_id

#        belongs_to :party_set
#        :class_name => 'PartyTester::Merge::Concept'

#        validate :valid_rifcs?
#        after_validation :clean_metadata
#        after_save :update_set_memberships

        @@schemas = {}

        # Indicates whether delete is supported.
        #
        def deleted?
          false
        end

        # Sets supported.
        #
        def self.sets
          false

          # TODO: fix this to allow the "test sets" to appear as OAI-PMH sets
          #PartyTester::Output::OAIPMH::Set.scoped
        end

        # RIF-CS XML namespace

        RIFCS_NS = 'http://ands.org.au/standards/rif-cs/registryObjects'

        #================================================================

        # Generate RIF-CS
        #
        def to_rif

          r_class = Thales::Datamodel::CLASS_FOR[ser_type]
          @data = r_class.new.deserialize(ser_data)

          desc = "foobar"
#          # Only output description element if it has a value
#          if ! description.blank?
#            desc = "<description type=\"full\">#{description}</description>"
#          else
#            desc = ''
#          end

          # Use the test set prefix as the group (is this correct?)
#          group = PartySet.find(partySet_id).prefix
          group = 'all'

          Nokogiri::XML::Builder.new { |xml|
            xml.registryObjects(xmlns: RIFCS_NS) {
              xml.registryObject(group: "Thales") {
                xml.key(uuid)
                xml.originatingSource("foobar")
                @data.to_rifcs(xml, updated_at)
              }
            }
          }.doc.root.to_xml
          
        end

        #================================================================

        # Methods to expose values for the Dublin Core formatter
        # (OAI::Provider::Metadata::DublinCore) to use.

        def identifier
          testident
        end

        def title
          "#{forename} #{surname}"
        end

        # Description method already provided by ActiveRecord
        #def description
        #end

      end # class Record

    end
  end
end
