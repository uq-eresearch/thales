#
# Copyright (C) 2012, The University of Queensland.

require 'nokogiri'

module Properties
  module Basic

    class Collection

      # ActiveModel

      include ActiveModel::Validations
      include ActiveModel::Conversion
      extend ActiveModel::Naming

      validates_presence_of :title, :description
      # validates_form_of :email, :with => /^$/
      # validates_length_of :title, :maximum => 255

      include ActiveModel::Serialization
      attr_accessor :attributes

      # Accessors

      attr_accessor :title
      attr_accessor :alt_titles
      attr_accessor :description
      attr_accessor :identifiers

      attr_accessor :for_codes
      attr_accessor :seo_codes
      attr_accessor :keywords

      attr_accessor :temporal_coverages
      attr_accessor :spatial_coverages

      attr_accessor :rights_access
      attr_accessor :rights_licence
      attr_accessor :rights_statement

      attr_accessor :emails
      attr_accessor :urls

      attr_accessor :creators
      attr_accessor :custodians
      attr_accessor :projects

      # Initialize

      def initialize(attr = nil)
        if attr
          @title = get_singular_value(attr['title'])
          @alt_titles = get_array_values(attr['altTitle'])
          @description = get_singular_value(attr['description'])
          @identifiers = get_array_values(attr['identifier'])
          @for_codes = get_array_values(attr['FoR'])
          @seo_codes = get_array_values(attr['SEO'])
          @keywords = get_array_values(attr['keyword'])
          @temporal_coverages = get_array_values(attr['temporal'])
          @spatial_coverages = get_array_values(attr['spatial'])
          @rights_access = get_singular_value(attr['rights_access'])
          @rights_licence = get_singular_value(attr['rights_licence'])
          @rights_statement = get_singular_value(attr['rights_statement'])
          @emails = get_array_values(attr['email'])
          @urls = get_array_values(attr['url'])
          @creators = get_array_values(attr['creator'])
          @custodians = get_array_values(attr['custodian'])
          @projects = get_array_values(attr['project'])
        else
          @alt_titles = []
          @identifiers = []
          @temporal_coverages = []
          @spatial_coverages = []
          @for_codes = []
          @seo_codes = []
          @keywords = []
          @emails = []
          @urls = []
          @creators = []
          @custodians = []
          @projects = []
        end
      end

      def get_singular_value(str)
        if str.nil? || str.blank?
          return nil 
        end
        str.strip
      end

      def get_array_values(hash)
        if hash.nil?
          return []
        end
        # hash contains { '1' => , '10' => , '11' => , '2' =>, '3' => ... }
        result = hash.keys.sort_by(&:to_i).map { |key| hash[key] }
        result.select { |str| (! str.blank?) }
      end

      # This ActiveModel model is not persisted. Returns false.

      def persisted?
        false # ActiveModel model is not persisted
      end
      
      def serialize
        #YAML::dump(self)

        builder= Nokogiri::XML::Builder.new do|xml|
          xml.record('xmlns' => 'http://uq.edu.au/2012/thales/basic') {
            if ! @title.nil?; xml.title @title end
            @alt_titles.each { |x| xml.alt_title x }
            if ! @description.nil?; xml.description @description end
            @identifiers.each { |x| xml.identifier x }

            @for_codes.each { |x| xml.FoR x }
            @seo_codes.each { |x| xml.SEO x }
            @keywords.each { |x| xml.keyword x }

            @temporal_coverages.each { |x| xml.temporal x }
            @spatial_coverages.each { |x| xml.spatial x }

            if ! @rights_access.nil?; xml.rights_access @rights_access end
            if ! @rights_licence.nil?; xml.rights_licence @rights_licence end
            if ! @rights_statement.nil?; xml.rights_statement @rights_statement end

            @emails.each { |x| xml.email x }
            @urls.each { |x| xml.url x }

            @creators.each { |x| xml.creator x }
            @custodians.each { |x| xml.custodian x }
            @projects.each { |x| xml.project x }
          }
        end

        builder.to_xml
      end

#      def serialize_single(value)
#        if ! value.nil?
#          if ! value.blank?
#            
#          end
#        end
#      end

      NS = { 'b' => 'http://uq.edu.au/2012/thales/basic' }

      def self.deserialize(str)
        #obj = YAML::load(str)

        doc = Nokogiri::XML(str)

        #doc = Nokogiri::XML(xmlstr)

        obj = Collection.new

        doc.xpath('/b:record/b:title', NS).each do |x|
          obj.title = x.inner_text
        end

        doc.xpath('/b:record/b:alt_title', NS).each do |alt|
          obj.alt_titles << alt.inner_text
        end

        doc.xpath('/b:record/b:description', NS).each do |x|
          obj.description = x.inner_text
        end

        doc.xpath('/b:record/b:identifier', NS).each do |x|
          obj.identifiers << x.inner_text
        end

        doc.xpath('/b:record/b:FoR', NS).each do |x|
          obj.for_codes << x.inner_text
        end
        doc.xpath('/b:record/b:SEO', NS).each do |x|
          obj.seo_codes << x.inner_text
        end
        doc.xpath('/b:record/b:keyword', NS).each do |x|
          obj.keywords << x.inner_text
        end

        doc.xpath('/b:record/b:temporal', NS).each do |x|
          obj.temporal_coverages << x.inner_text
        end

        doc.xpath('/b:record/b:spatial', NS).each do |x|
          obj.spatial_coverages << x.inner_text
        end

        doc.xpath('/b:record/b:rights_access', NS).each do |x|
          obj.rights_access = x.inner_text
        end
        doc.xpath('/b:record/b:rights_licence', NS).each do |x|
          obj.rights_licence = x.inner_text
        end
        doc.xpath('/b:record/b:rights_statement', NS).each do |x|
          obj.rights_statement = x.inner_text
        end

        doc.xpath('/b:record/b:email', NS).each do |x|
          obj.emails << x.inner_text
        end
        doc.xpath('/b:record/b:url', NS).each do |x|
          obj.urls << x.inner_text
        end

        doc.xpath('/b:record/b:creator', NS).each do |x|
          obj.creators << x.inner_text
        end
        doc.xpath('/b:record/b:custodian', NS).each do |x|
          obj.custodians << x.inner_text
        end
        doc.xpath('/b:record/b:project', NS).each do |x|
          obj.projects << x.inner_text
        end

        obj
      end

    end # class Collection

  end
end
