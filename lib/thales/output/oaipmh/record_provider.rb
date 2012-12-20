# OAI Record provider.
#
# Copyright (c) 2012, The University of Queensland. (ITEE eResearch Lab)

#----------------------------------------------------------------

require 'oai'

require 'setting'
require 'oaipmh_record'
require_relative 'rifcs_format'

module Thales
  module Output
    module OAIPMH

      # TODO: refactor this code to merge it with the Ruby on Rails
      # created model in app/models/party_record.rb

      class RecordProvider < OAI::Provider::Base

        settings = Setting.instance

        # Configuring the default provider

        repository_name settings.oaipmh_repositoryName
        admin_email settings.oaipmh_adminEmail

        source_model OAI::Provider::ActiveRecordWrapper.new(OaipmhRecord)

        register_format(RifcsFormat.instance)

        # Returns the prefix used by ruby-oai to create the OAI-PMH
        # unique identifers. Each record in the OAI-PMH feed has
        # a unique identifier that is this prefix concatenated with
        # a slash character and the OAI-PMH record.id.
        #
        # See the identifier_for method in ruby-oai's
        # oai/provider/response/record_response.rb file.

        def self.prefix
          "oai:%s" % URI.parse(self.url).host
        end

      end # class RecordProvider

    end
  end
end
