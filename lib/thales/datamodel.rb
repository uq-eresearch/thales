#!/bin/env ruby
#
# Copyright (c) 2012, The University of Queensland. (ITEE eResearch Lab)

#----------------------------------------------------------------

require_relative 'datamodel/e_research'

module Thales
  module Datamodel

    E_RESEARCH_COLLECTION = 1
    E_RESEARCH_PARTY = 2
    E_RESEARCH_ACTIVITY = 3
    E_RESEARCH_SERVICE = 4

    CLASS_FOR = {
      E_RESEARCH_COLLECTION => Thales::Datamodel::EResearch::Collection,
      E_RESEARCH_PARTY => Thales::Datamodel::EResearch::Party,
      E_RESEARCH_ACTIVITY => Thales::Datamodel::EResearch::Activity,
      E_RESEARCH_SERVICE => Thales::Datamodel::EResearch::Service,
    }

    LABEL_FOR = {
      E_RESEARCH_COLLECTION => 'collection',
      E_RESEARCH_PARTY => 'party',
      E_RESEARCH_ACTIVITY => 'activity',
      E_RESEARCH_SERVICE => 'service',
    }

    IDENTITY_FOR = {
      Thales::Datamodel::EResearch::Collection::TYPE => E_RESEARCH_COLLECTION,
      Thales::Datamodel::EResearch::Party::TYPE => E_RESEARCH_PARTY,
      Thales::Datamodel::EResearch::Activity::TYPE => E_RESEARCH_ACTIVITY,
      Thales::Datamodel::EResearch::Service::TYPE => E_RESEARCH_SERVICE,
    }
  end
end

#EOF
