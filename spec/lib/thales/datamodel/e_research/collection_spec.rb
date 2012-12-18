# -*- coding: utf-8 -*-
# RSpec

require 'nokogiri'
require 'thales/datamodel/e_research'

describe Thales::Datamodel::EResearch::Collection do

  let(:record) {
    r = Thales::Datamodel::EResearch::Collection.new
    r.subtype << 'http://ns.research.data.uq.edu.au/2012/eResearch/subtype/collection/collection'
    r.title << 'test title'
    r.title_alt << 'test alternative title 1'
    r.title_alt << 'test alternative title 2'
    r
  }

  describe "#title" do

    it 'is shortcut for the title property' do
      values = record.title
      values.should have(1).item
      values[0].should == 'test title'
    end

  end

  describe "#initialize" do

    it 'populates using form parameters' do

      pl = Thales::Datamodel::Cornerstone::PropertyLink

      expected_record = Thales::Datamodel::EResearch::Collection.new
      expected_record.subtype << 'http://ns.research.data.uq.edu.au/2012/eResearch/subtype/collection/collection'
      expected_record.title << 'Test title'
      expected_record.title_alt << 'Test alternative title 1'
      expected_record.title_alt << 'Test alternative title 2'
      expected_record.title_alt << 'Test alternative title 3'
      expected_record.description << 'Test description'
      expected_record.tag_keyword << 'rspec'
      expected_record.tag_keyword << 'tdd'
      expected_record.tag_FoR << pl.new('http://purl.org/asc/1297.0/2008/for/1601', 'Anthropology')
      expected_record.createdBy << pl.new('http://example.com', 'Example Hint')

      attr = {
        "subtype"=>"http://ns.research.data.uq.edu.au/2012/eResearch/subtype/collection/collection",
        "title"=>"Test title",
        "title_alt"=>{
          "0"=>"Test alternative title 1",
          "1"=>"Test alternative title 2",
          "2"=>"Test alternative title 3",
          "3"=>""},
        "description"=>"  Test      description  ",
        "identifier"=>{"0"=>""},
        "tag_keyword"=>{
          "0"=>"rspec    ",
          "1"=>"   ",
          "2"=>"    tdd"},
        "tag_FoR"=>{"0"=>"http://purl.org/asc/1297.0/2008/for/1601 Anthropology"},
        "tag_SEO"=>{"0"=>""},
        "contact_email"=>{"0"=>""},
        "web_page"=>{"0"=>""},
        "temporal"=>{"0"=>""},
        "spatial"=>{"0"=>""},
        "rights_access"=>"",
        "rights_statement"=>"",
        "rights_licence"=>"",
        "createdBy"=>"http://example.com Example Hint",
      }

      r = Thales::Datamodel::EResearch::Collection.new(attr)
      r.should == expected_record
    end

  end


  describe "#to_rifcs" do

    it 'works' do
      pl = Thales::Datamodel::Cornerstone::PropertyLink

      c = Thales::Datamodel::EResearch::Collection.new
      c.subtype << 'http://ns.research.data.uq.edu.au/2012/eResearch/subtype/collection/collection'
      c.title << Thales::Datamodel::Cornerstone::PropertyText.new('Test title')
      c.title_alt << 'Test alternative title 1'
      c.title_alt << 'Test alternative title 2'
      c.title_alt << 'Test alternative title 3'
      c.description << 'Test description'
      c.tag_keyword << 'rspec'
      c.tag_keyword << 'tdd'
      c.tag_FoR << pl.new('http://purl.org/asc/1297.0/2008/for/1601', 'Anthropology')
      c.createdBy << pl.new('http://example.com', 'Example Hint')
      c.managedBy << pl.new('http://example.com', 'Example Hint')
      c.accessedVia << pl.new('http://example.com', 'Some service')
      c.referencedBy << pl.new('http://example.com', 'Some publication')

      builder = Nokogiri::XML::Builder.new do |xml|
        c.to_rifcs(xml)
      end

      # puts "\nDEBUG DUMP OF COLLECTION RIF-CS:\n#{builder.to_xml}"

      ns = { 'r' => 'http://ands.org.au/standards/rif-cs/registryObjects' }

      doc = Nokogiri::XML(builder.to_xml)
      doc.xpath('/*', ns).each do |e|
        e.name.should == 'collection'
      end
      type_attr = doc.xpath('/r:collection/@type', ns)
      type_attr.size.should == 1
      type_attr[0].text.should == 'collection'

      primary_name = doc.xpath('//r:name[@type="primary"]', ns)
      primary_name.size.should == 1
      pn_nameParts = primary_name[0].xpath('r:namePart', ns)
      pn_nameParts.size.should == 1
      pn_nameParts[0].text.should == 'Test title'

      # Alternative names

      alt_name = doc.xpath('//r:name[@type="alternative"]', ns)
      alt_name.size.should == 3

      # FoR codes are converted from URI to just a number
      count = 0
      doc.xpath('//r:subject[@type="anzsrc-for"]', ns).each do |e|
        e.text.should == '1601'
        count += 1
      end
      count.should == 1

    end

  end

end

#EOF
