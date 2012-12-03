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

require 'models/property'
require 'models/record'
require 'models/entry'

require 'thales/datamodel/e_research'

#----------------------------------------------------------------

PROG=File.basename $0

DEFAULT_DB_ADAPTER = 'development'

THALES_SYSTEM_NS = 'http://ns.research.data.uq.edu.au/2012/thales/db'

NS = {
  'db' => THALES_SYSTEM_NS,
  'c' => Thales::Datamodel::Cornerstone::Record::CONTAINER_NS,
}

#----------------------------------------------------------------

def edit_collection_property_id
  # Obtain the internal ID for the 'test collection' property

  edit_collection_uuid = 'd4cdb36b73a94b5295ac93232d5ce7b1'

  relation = Property.where(:uuid => edit_collection_uuid)
  if relation.size != 1
    raise "Internal error: property #{edit_collection_uuid}: expecting 1, #{relation.size} found"
  end
    
  relation.first.id # result
end


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

def check_uuids_dont_exist(records)

  clashing = records.select { |r| Record.where(:uuid => r[:uuid]).size != 0 }

  if ! clashing.empty?
    $stderr.puts "Error: #{clashing.size} UUIDs already exist"
    clashing.each { |u| $stderr.puts "  #{u}" }
    exit 1
  end
end

def create_records(records)

  records.each do |r|

    entry = Entry.new
    entry.property_id = edit_collection_property_id
    entry.order = 1
    entry.value = r[:data].serialize
    entry.save()

    obj = Record.new
    obj.uuid = r[:uuid]
    obj.entries << entry

    if ! obj.save
      $stderr.puts "Error: could not save new record in database"
      exit 1
    end

  end
end

def import(options)

  records = []

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

          entries = db_record.xpath('db:entry', NS)
          if entries.size != 1
            raise "#{fname}: incorrect number of entries in record"
          end

          entries.each do |db_entry|
            db_entry.xpath('c:record', NS).each do |c_record|
              r = Thales::Datamodel::Cornerstone::Record.new
              r.deserialize(c_record)
#              puts "---"
#              puts r.serialize
              records << { :uuid => db_record[:uuid], :data => r }
            end
          end

        end

      end

      connect(options[:adapter])
      check_uuids_dont_exist(records)
      create_records(records)

    rescue Errno::ENOENT => e
      raise "import file: #{e}"
    end

  end


#            # Parse text properties
#            root.xpath('c:prop', NS).each do |element|
#              property_append(element.attribute('type').content,
#                              PropertyText.new(element.inner_text))
#            end
#
#            # Parse links
#            root.xpath('c:link', NS).each do |element|
#              property_append(element.attribute('type').content,
#                              PropertyLink.new(element.attribute('uri').content,
#                                               element.inner_text))
#            end
#          end
#
end

def export(options)
  connect(options[:adapter])

  builder = Nokogiri::XML::Builder.new do |xml|
    xml.records('xmlns' => THALES_SYSTEM_NS) do

      Record.all.each do |record|

        # Load the record's collection data
        collection = Thales::Datamodel::EResearch::Collection.new

        entries = record.entries.where(:property_id =>
                                       edit_collection_property_id)
        if entries.size != 1
          # Expecting only one "edit collection" property
          raise "Internal error: incorrect number of 'edit collection'"
        end
        collection.deserialize(entries.first.value)

        xml.record ({:uuid => record.uuid}) {
          xml.entry {
            collection.serialize_xml(xml)
          }
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
