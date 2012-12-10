# -*- coding: utf-8 -*-
# RSpec

require 'nokogiri'
require 'thales/datamodel/e_research'

describe Thales::Datamodel::EResearch::Collection do

  let(:record) {
    r = Thales::Datamodel::EResearch::Collection.new
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

      expected_record = Thales::Datamodel::EResearch::Collection.new
      expected_record.title << 'Test title'
      expected_record.title_alt << 'Test alternative title 1'
      expected_record.title_alt << 'Test alternative title 2'
      expected_record.title_alt << 'Test alternative title 3'
      expected_record.description << 'Test description'
      expected_record.tag_keyword << 'rspec'
      expected_record.tag_keyword << 'tdd'
      expected_record.tag_FoR << '12345'
      expected_record.createdBy <<
        Thales::Datamodel::Cornerstone::PropertyLink.new('http://example.com',
                                                         'Example Hint')

      attr = {
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
        "tag_FoR"=>{"0"=>"12345"},
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
      c = Thales::Datamodel::EResearch::Collection.new
      c.title << Thales::Datamodel::Cornerstone::PropertyText.new('title')

      pl = Thales::Datamodel::Cornerstone::PropertyLink

      c = Thales::Datamodel::EResearch::Collection.new
      c.title << 'Test title'
      c.title_alt << 'Test alternative title 1'
      c.title_alt << 'Test alternative title 2'
      c.title_alt << 'Test alternative title 3'
      c.description << 'Test description'
      c.tag_keyword << 'rspec'
      c.tag_keyword << 'tdd'
      c.tag_FoR << '12345'
      c.createdBy << pl.new('http://example.com', 'Example Hint')
      c.managedBy << pl.new('http://example.com', 'Example Hint')
      c.accessedVia << pl.new('http://example.com', 'Some service')
      c.referencedBy << pl.new('http://example.com', 'Some publication')

      builder = Nokogiri::XML::Builder.new do |xml|
        c.to_rifcs(xml)
      end

      puts builder.to_xml
        #.should be_nil
    end

  end

end

#EOF
