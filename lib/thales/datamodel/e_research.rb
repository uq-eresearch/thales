#!/bin/env ruby
#
# The eResearch module defines schemas for Cornerstone records for
# representing concepts from ISO 2146:2010 (Information and
# documentation - Registry services for libraries and related
# organizations). Namely, collections, parties, activities and
# services.
#
# Copyright (c) 2012, The University of Queensland. (ITEE eResearch Lab)

basedir = File.expand_path(File.dirname(__FILE__))
require "#{basedir}/cornerstone"
require "#{basedir}/e_research/collection"
require "#{basedir}/e_research/party"
require "#{basedir}/e_research/activity"
require "#{basedir}/e_research/service"

#EOF
