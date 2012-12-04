#!/bin/env ruby
#
# Copyright (C) 2012, The University of Queensland. (ITEE eResearch Lab)

basedir = File.expand_path(File.dirname(__FILE__))
require "#{basedir}/datamodel/e_research"

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
  end
end

#EOF
