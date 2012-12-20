# OAI Record.
#
# Record class.
#
# This class is passed to the OAI ActiveRecordWrapper class
# to use.
#
# Copyright (c) 2012, The University of Queensland. (ITEE eResearch Lab)
#----------------------------------------------------------------

class OaipmhRecord < ActiveRecord::Base

  # Indicates if the record has been withdrawn. All OAI-PMH records
  # always appear in the OAI-PMH feed. Those that have been withdrawn
  # or do not have an associated record are in the feed as deleted
  # records.  That is, only those that have not been withdrawn and
  # have an associated record appear as non-deleted records.

  attr_accessible :withdrawn

  # Link to record. This can be nil, which means the underlying record has
  # been removed from the system, but the OAI-PMH model remains so that
  # a deletion record appears in the feed for it.

  attr_accessible :record_id

  belongs_to :record

  #----------------------------------------------------------------

  # Indicates to ruby-oai whether this record has been deleted or
  # not. Note: deleted records still appear in the feed.

  def deleted?
    return (withdrawn || record.nil?)
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

  # Generate RIF-CS from the associated record.
  #
  # ==== Returns
  #
  # RIF-CS XML representing the record.

  def to_rif
    settings = Setting.instance

    Nokogiri::XML::Builder.new { |xml|
      xml.registryObjects(xmlns: RIFCS_NS) {
        xml.registryObject(group: settings.rifcs_group) {
          xml.key(record.uuid)
          xml.originatingSource(settings.rifcs_originatingSource)

          r_class = Thales::Datamodel::CLASS_FOR[record.ser_type]
          @data = r_class.new.deserialize(record.ser_data)
          @data.to_rifcs(xml, record.updated_at)
        }
      }
    }.doc.root.to_xml
    
  end

  #================================================================

  # Exposes an identifier for the ruby-oai built-in Dublin Core
  # provider. See OAI::Provider::Metadata::DublinCore.
  #
  # ==== Returns
  #
  # An array (possibly empty) of identifiers.

  def identifier
    # TODO: Don't parse ser_type every time
    r_class = Thales::Datamodel::CLASS_FOR[record.ser_type]
    data = r_class.new.deserialize(record.ser_data)

    data.identifier
  end

  # Exposes a title for the ruby-oai built-in Dublin Core
  # provider. See OAI::Provider::Metadata::DublinCore.
  #
  # ==== Returns
  #
  # A single string value.

  def title
    # TODO: Don't parse ser_type every time
    r_class = Thales::Datamodel::CLASS_FOR[record.ser_type]
    data = r_class.new.deserialize(record.ser_data)

    data.display_title
  end

  # Exposes a description for the ruby-oai built-in Dublin Core
  # provider. See OAI::Provider::Metadata::DublinCore.
  #
  # ==== Returns
  #
  # An array containing zero or one description.

  def description
    # TODO: Don't parse ser_type every time
    r_class = Thales::Datamodel::CLASS_FOR[record.ser_type]
    data = r_class.new.deserialize(record.ser_data)

    data.description
  end

end
