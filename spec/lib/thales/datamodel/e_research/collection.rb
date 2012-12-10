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
