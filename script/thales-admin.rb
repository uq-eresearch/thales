#!/bin/env ruby
#
# Copyright (C) 2012, The University of Queensland. (ITEE eResearch Lab)

VERBOSE = true

$LOAD_PATH.unshift File.dirname(__FILE__) + '/../app'
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

#require 'logger'
require 'optparse'
require 'nokogiri'
require 'active_record'
require 'pg'
require 'uuid'

require 'models/property'
require 'models/record'
require 'models/entry'

require 'thales/datamodel'

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

def create_update_records(items)

  items.each do |item|

    existing = item[:uuid] ? Record.where(:uuid => item[:uuid]) : nil

    if existing.nil? || existing.size == 0
      # Create a new record

      r = Record.new
      r.uuid = item[:uuid] ? item[:uuid] : UUID.new.generate(:compact)
      r.ser_type = item[:ser_type]
      r.ser_data = item[:data].serialize 

      if ! r.save
        $stderr.puts "Error: could not save new record in database"
        exit 1
      end

      item[:status] = ACTION_CREATED

    elsif existing.size == 1
      # Replace existing record that has the same UUID
      r = existing.first
      r.ser_type = item[:ser_type]
      r.ser_data = item[:data].serialize 
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
    puts "Importing: #{fname}"

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

          uuid_element = db_record.xpath('db:uuid', NS).first
          type_uri = db_record.xpath('db:type', NS).first.inner_text
          ser_type = Thales::Datamodel::IDENTITY_FOR[type_uri]
          r_class = Thales::Datamodel::CLASS_FOR[ser_type]

          db_record.xpath('c:data', NS).each do |c_data|
            r = r_class.new.deserialize(c_data)
            item = {
              :ser_type => ser_type,
              :data => r,
            }
            if uuid_element
              item[:uuid] = uuid_element.inner_text
            end
            items << item
          end

        end

      end

      connect(options[:adapter])

      dup = duplicate_uuids(items)
      if ! dup.empty? && ! options[:force]
        $stderr.puts "Error: #{dup.size} UUIDs already exist (use --force to overwrite)"
        dup.each { |u| $stderr.puts "  #{u[:uuid]}" }
        exit 1
      end
      
      create_update_records(items)

      if options[:verbose]
        n = items.count { |i| i[:status] == ACTION_CREATED }
        puts "Created #{n} records"
        n = items.count { |i| i[:status] == ACTION_UPDATED }
        puts "Updated #{n} records"
        puts "Total #{items.size} records"
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
          xml.uuid(record.uuid)
          xml.type(r_class::TYPE)
          data.serialize_xml(xml)
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

  if options[:force] && options[:export]
    $stderr.puts "Usage error: --force cannot be used with --export"
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
    elsif options[:import]
      import(options)
    else
      puts "#{PROG}: no action specified (--help for help)"
      exit 2
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
