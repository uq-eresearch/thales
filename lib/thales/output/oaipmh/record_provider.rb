# OAI Record provider.
#
# Copyright (c) 2012, The University of Queensland. (ITEE eResearch Lab)

#----------------------------------------------------------------

require 'oai'

require 'setting'
require 'thales/output/oaipmh/record'
require 'thales/output/oaipmh/rifcs_format'

module Thales
  module Output
    module OAIPMH

      # TODO: refactor this code to merge it with the Ruby on Rails
      # created model in app/models/party_record.rb

      class RecordProvider < OAI::Provider::Base
        
        # Obtain the email address to use as the adminEmail.  Either
        # from the ADMIN_EMAIL environment variable, or derive it from
        # the current user and hostname.

       
        #----
        # Configuring the default provider

        settings = Setting.instance

        repository_name settings.oaipmh_repositoryName
        admin_email settings.oaipmh_adminEmail

        rclass = Thales::Output::OAIPMH::Record
        source_model OAI::Provider::ActiveRecordWrapper.new(rclass)

        register_format(RifcsFormat.instance)

        def self.prefix
          "oai:%s" % URI.parse(self.url).host
        end

      end # class RecordProvider

    end
  end
end
