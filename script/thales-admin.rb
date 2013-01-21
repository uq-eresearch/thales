#!/bin/env ruby
#
# Copyright (c) 2012, The University of Queensland. (ITEE eResearch Lab)

VERBOSE = true

#require 'logger'
require 'optparse'
require 'nokogiri'
require 'active_record'
require 'pg'

require_relative '../app/models/property'
require_relative '../app/models/record'
require_relative '../app/models/oaipmh_record'
#require_relative '../app/models/entry'

require_relative '../lib/thales/datamodel'

#----------------------------------------------------------------

PROG=File.basename $0

DEFAULT_DB_ADAPTER = 'development'

THALES_SYSTEM_NS = 'http://ns.research.data.uq.edu.au/2012/thales/db'

NS = {
  'db' => THALES_SYSTEM_NS,
  'c' => Thales::Datamodel::Cornerstone::Record::CONTAINER_NS,
}

ACTION_CREATED = 1
ACTION_UPDATED = 2

#----------------------------------------------------------------

def connect(adapter_name)
  fname = File.join(File.dirname(__FILE__), '..', 'config', 'database.yml')
  db_config = YAML::load(File.open(fname))
  if db_config.nil?
    raise "Error: could not load config: #{fname}"
  end

  adapter_config = db_config[adapter_name]
  if adapter_config.nil?
    raise "Error: unknown adaptor in database.yml: #{adapter_name}"
  end

  #ActiveRecord::Base.logger = Logger.new('my-debug.log')
  ActiveRecord::Base.establish_connection(adapter_config)

end

def duplicate_uuids(items)
  items.select do |item|
    item[:uuid] ? Record.where(:uuid => item[:uuid]).size != 0 : false
  end
end

# Sets/changes the OAI-PMH publishing status of a record.
#
# Note: it is not possible to change an already published record
# (one that is currently active or deleted) to an unpublished one.
# That would violate the strict deleted record tracking in OAI-PMH.
# A future enhancement could be to relax/override this restriction
# to support transient or no deletion tracking in the OAI-PMH feed.
#
# ==== Parameters
#
# +new_status+:: string containing unpublished, active or deleted.
# +r+:: the record

def set_oaipmh_status(new_status, r)

  if r.oaipmh_record.nil?
    # Currently unpublished (also true when record is new)
    if new_status == 'active'
      r.build_oaipmh_record(withdrawn: false)
    elsif new_status == 'deleted'
      r.build_oaipmh_record(withdrawn: true)
    elsif new_status == 'unpublished'
      # not published: so do not create an oaipmh_record
    else
      raise "internal error: #{new_status}"
    end

  else
    # Currently published (active or deleted): change existing oaipmh_record
    if new_status == 'active'
      r.oaipmh_record.withdrawn = false
    elsif new_status == 'deleted'
      r.oaipmh_record.withdrawn = true
    elsif new_status == 'unpublished'
      s = (r.oaipmh_record.withdrawn ? 'deleted' : 'active')
      $stderr.puts "Warning: OAI-PMH status: cannot change #{s} to unpublished: #{r.uuid}"
    else
      raise "internal error: #{new_status}"
    end
    r.oaipmh_record.save
  end

end

def create_update_records(items)

  items.each do |item|

    existing = item[:uuid] ? Record.where(:uuid => item[:uuid]) : nil

    if existing.nil? || existing.size == 0
      # Create a new record

      r = Record.new
      r.uuid_set(item[:uuid])
      r.data_set(item[:ser_type], item[:data])
      set_oaipmh_status(item[:oaipmh_status], r)

      if ! r.save
        $stderr.puts "Error: could not save new record in database"
        exit 1
      end

      item[:status] = ACTION_CREATED

    elsif existing.size == 1
      # Replace existing record that has the same UUID
      r = existing.first
      r.data_set(item[:ser_type], item[:data])
      set_oaipmh_status(item[:oaipmh_status], r)

      if ! r.save
        $stderr.puts "Error: could not update record: #{item[:uuid]}"
        exit 1
      end

      item[:status] = ACTION_UPDATED

    else
      $stderr.puts "Error: database has multiple records with same UUID: #{item[:uuid]}"
      exit 1
    end

  end
end

def import(options)

  items = []

  options[:import].each do |fname|
    if options[:verbose]
      puts "Importing: #{fname}"
    end

    begin
      File.open(fname, 'r') do |f|

        doc = Nokogiri::XML(f)

        # Check root element is correct

        root = doc.root
        root_ns = root.namespace

        if (root.name != 'records' ||
            root_ns.nil? || root_ns.href != THALES_SYSTEM_NS)
          n = root_ns.nil? ? '' : "{#{root_ns.href}}"
          raise "#{fname}: unexpected root element: #{n}#{root.name}"
        end

        # Process all records

        root.xpath('db:record', NS).each do |db_record|

          uuid_element = db_record.xpath('db:id', NS).first
          type_uri = db_record.xpath('db:type', NS).first.inner_text
          ser_type = Thales::Datamodel::IDENTITY_FOR[type_uri]
          r_class = Thales::Datamodel::CLASS_FOR[ser_type]
          oaipmh_status = db_record.xpath('db:oaipmh_status', NS).first.try(:inner_text) || 'unpublished'
          if ! ['unpublished', 'active', 'deleted' ].include?(oaipmh_status)
            raise "#{fname}: incorrect OAI-PMH status value: #{oaipmh_status}"
          end

          db_record.xpath('c:data', NS).each do |c_data|
            r = r_class.new.deserialize(c_data)
            item = {
              :ser_type => ser_type,
              :data => r,
              :oaipmh_status => oaipmh_status,
            }
            if uuid_element
              item[:uuid] = uuid_element.inner_text
            end
            items << item
          end

        end

      end

      connect(options[:adapter])

      # Check for UUID clashes

      dup = duplicate_uuids(items)
      if ! dup.empty? && ! options[:force]
        $stderr.print "Error: #{dup.size} UUIDs already exist"
        if options[:verbose].nil?
          $stderr.print ', use --verbose to list them'
        end
        $stderr.puts ' (use --force to replace them)'

        if options[:verbose]
          dup.each { |u| $stderr.puts "  #{u[:uuid]}" }
        end
        exit 1
      end

      # Update database with imported records

      create_update_records(items)

      # Verbose

      if options[:verbose]
        num_created = items.count { |i| i[:status] == ACTION_CREATED }
        num_updated = items.count { |i| i[:status] == ACTION_UPDATED }
        updated_str = options[:force] ? ", #{num_updated} updated" : ''
        puts "  #{items.size} records (#{num_created} created#{updated_str})"
      end

    rescue Errno::ENOENT => e
      raise "import file: #{e}"
    end

  end

end

def export(options)
  connect(options[:adapter])

  builder = Nokogiri::XML::Builder.new do |xml|
    xml.records('xmlns' => THALES_SYSTEM_NS) do

      Record.all.each do |record|

        # Load the record's collection data
        r_class = Thales::Datamodel::CLASS_FOR[record.ser_type]
        data = r_class.new.deserialize(record.ser_data)

        xml.record {
          xml.id(record.uuid)
          xml.type(r_class::TYPE)
          data.serialize_xml(xml)

          oai = record.oaipmh_record
          xml.oaipmh_status(oai.nil? ? 'unpublished' : (oai.withdrawn ? 'deleted' : 'active'))

        }
      end # Record.all.each

    end
  end

  fname = options[:output]
  if fname
    File.open(fname, 'w') { |f| f.puts builder.to_xml }
  else
    $stderr.puts builder.to_xml
  end
end

def delete(options)
  connect(options[:adapter])

  count = 0
  Record.all.each do |record|
    record.destroy
    count += 1
  end

  if options[:verbose]
    puts "#{count} records deleted"
  end
end

#----------------------------------------------------------------
# Process command line arguments.
# Returns hash of options (and arguments for options that have them).
# ARGV is set to the remaining parameters.

def process_arguments
  options = {}
  options[:adapter] = DEFAULT_DB_ADAPTER

  opt_parser = OptionParser.new do |opt|
    opt.banner = "Usage: #{PROG} [options]"
    opt.separator  "Options:"

    opt.on("-o", "--output filename", "file to write XML output to") do |x|
      options[:output] = x
    end

    opt.on("-e", "--export", "export records") do
      options[:export] = true
    end

    opt.on("-i", "--import filename", "import records (repeatable)") do |x|
      if options[:import].nil?
        options[:import] = []
      end
      options[:import] << x
    end

    opt.on("-f", "--force", "force import of records with same UUID") do
      options[:force] = true
    end

    opt.on("-D", "--delete", "delete all records") do
      options[:delete] = true
    end

    opt.on("-a", "--adapter name",
           "database adapter (default=\"#{DEFAULT_DB_ADAPTER}\")") do |x|
      options[:adapter] = x
    end

    opt.on("-v", "--verbose", "print extra information") do
      options[:verbose] = true
    end

    opt.on("-h", "--help", "show help") do
      puts opt_parser
      exit 0
    end
  end

  opt_parser.parse!

  if ! ARGV.size.zero?
    puts "Usage error: extra arguments supplied (--help for help)"
    exit 2
  end

  if ! (options[:export] || options[:delete] || options[:import])
    puts "#{PROG}: no action specified (--help for help)"
    exit 2
  end

  if options[:force] && ! options[:import]
    $stderr.puts "Usage error: --force only works with --import"
    exit 2
  end

  if options[:output] && ! options[:export]
    $stderr.puts "Usage error: --output only works with --export"
    exit 2
  end

  return options
end

#----------------------------------------------------------------

def main

  begin
    options = process_arguments()

    if options[:export]
      export(options)
    end

    if options[:delete]
      delete(options)
    end

    if options[:import]
      import(options)
    end

  rescue RuntimeError => s
    $stderr.puts "Error: #{s}"
    exit 1
  rescue PG::Error => e
    $stderr.puts "Error: PosgreSQL: #{e}"
    exit 1
  end

  return 0
end

exit main

#EOF
