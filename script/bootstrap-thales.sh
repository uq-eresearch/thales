#!/bin/bash
#
# This script is used to create the Ruby on Rails project for Thales,
# initialize the environment and generate the initial set of models.
#
# Note: must run as bask (not sh) so that sourcing the RVM script
# to make `rvm` a function will work.
#
# Hoylen Sue <h.sue@uq.edu.au>
#
# Copyright (C) 2012, The University of Queensland.
#----------------------------------------------------------------

PROJECTNAME=thales

if [ -e "${PROJECTNAME}" ]; then
  echo "Error: project directory already exists: ${PROJECTNAME}" >&2
  exit 1
fi

which rails > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Error: command not available: rails (check Ruby installation and gems)" >&2
  exit 1
fi

echo "Creating new Rails project"
rails new ${PROJECTNAME} --skip-bundle --database=postgresql --quiet
if [ $? -ne 0 ]; then exit 1; fi

cd ${PROJECTNAME}

# Load RVM into a shell session *as a function*
if [ -e "$HOME/.rvm/scripts/rvm" ]; then
  source "$HOME/.rvm/scripts/rvm"
  RVMTYPE=`type -t rvm`
  if [ "${RVMTYPE}" != 'function' ]; then
    echo "Error: could not load rvm as a function: rvm is a $RVMTYPE" >&2
    # Are you using the right shell? Works with bash, but not sh.
    exit 1
  fi
fi

echo "Creating project .rvmrc file"
rvm --rvmrc --create ruby-1.9.3@${PROJECTNAME}
if [ $? -ne 0 ]; then exit 1; fi

rvm rvmrc trust .
if [ $? -ne 0 ]; then exit 1; fi

# Modify Gemfile to use therubyracer
sed --in-place "s/# gem 'therubyracer/gem 'therubyracer/" Gemfile
if [ $? -ne 0 ]; then exit 1; fi

echo "Running bundle install"
bundle install --quiet
if [ $? -ne 0 ]; then exit 1; fi

echo "Generating models"

# Schemas and properties

rails generate scaffold Property \
  uuid:string \
  name:string \
  shortname:string \
  description:text \
  --quiet
if [ $? -ne 0 ]; then exit 1; fi

rails generate scaffold Schema \
  uuid:string \
  name:string \
  shortname:string \
  --quiet

rails generate model PropertySchema \
  schema:references \
  order:integer \
  property:references \
  --quiet

# Main concept is a record

rails generate scaffold Record \
  uuid:string \
  --quiet

rails generate model RecordSchema \
  record:references \
  schema:references \
  --quiet

# Records are made up of properties (data elements)

rails generate model PropertyRecord \
  record:references \
  property:references \
  order:integer \
  value:text \
  --quiet

# Users

rails generate scaffold Role \
  uuid:string \
  name:string \
  shortname:string \
  --quiet

rails generate scaffold User \
  uuid:string \
  surname:string \
  givenname:string \
  --quiet

rails generate scaffold Authority \
  uuid:string \
  name:string \
  shortname:string \
  --quiet

rails generate model IdentifierUser \
  user:references \
  authority:references \
  value:string \
  --quiet

# Records are associated with users

rails generate scaffold Capacity \
  uuid:string \
  name:string \
  shortname:string \
  --quiet

rails generate model RecordUser \
  record:references \
  capacity:references \
  user:references \
  --quiet

#EOF
