# -*- coding: utf-8 -*-
# RSpec

require 'thales/datamodel/cornerstone'

describe Thales::Datamodel::Cornerstone::Record do

  TEST_GID = 'http://ns.example.com/2012/property/test'
  OTHER_GID = 'http://ns.example.com/2012/property/other'

  let(:record) {
    r = Thales::Datamodel::Cornerstone::Record.new
    r.property_append(TEST_GID,
                      Thales::Datamodel::Cornerstone::PropertyText.new('first'))
    r
  }

  describe "#size" do

    it 'is zero for empty records' do
      blank = Thales::Datamodel::Cornerstone::Record.new
      blank.size.should == 0
    end

    it 'is one when there is one property' do
      record.size.should == 1
    end

    it 'increments for each additional property' do
      v = Thales::Datamodel::Cornerstone::PropertyText.new('another value')
      record.property_append(OTHER_GID, v)
      record.size.should == 2
    end

  end

  describe "#property_populated?" do

    it 'is true for set properties' do
      record.property_populated?(TEST_GID).should be_true
    end

    it 'is false for unset properties' do
      record.property_populated?(OTHER_GID).should be_false
    end

  end

  describe "#property_get" do

    it 'retrieves set properties' do
      p = record.property_get(TEST_GID)
      p.should have(1).items
      p[0].should == 'first'
    end

    it 'retrieves empty array for unset properties' do
      record.property_get(OTHER_GID).should be_empty
    end
  end

  describe "#property_append" do

    it 'sets the first value' do
      v = Thales::Datamodel::Cornerstone::PropertyText.new('initial value')
      record.property_append(OTHER_GID, v)
      p = record.property_get(OTHER_GID)
      p.should have(1).items
      p[0].should equal v
    end

    it 'adds to existing values' do
      v = Thales::Datamodel::Cornerstone::PropertyText.new('additional value')
      record.property_append(TEST_GID, v)
      p = record.property_get(TEST_GID)
      p.should have(2).items
      p[1].should equal v
    end

  end

  describe "#initialize" do

    it 'initializes record with no properties' do
      r = Thales::Datamodel::Cornerstone::Record.new
      count = 0
      r.property_all { |gid, value| count += 1 }
      count.should == 0
    end

    it 'ignores attr when there is no profile' do
      attr = {
        "utf8"=>"✓",
        "authenticity_token"=>"URlwvbuEioZoyuq9UrFONCM2si+e5Qbx5GQrnD3xC4w=",
        "record"=>{"title"=>"Test title",
          "title_alt"=>{"0"=>"Test alternative title 1",
            "1"=>"Test alternative title 2",
            "2"=>"Test alternative title 3",
            "3"=>""},
          "description"=>"Default description",
          "identifier"=>{"0"=>""},
          "tag_keyword"=>{"0"=>"termite", "1"=>"pest"},
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
        },
        "commit"=>"Create Record"}

      r = Thales::Datamodel::Cornerstone::Record.new(attr)
      r.size.should == 0
    end
  end

  describe "#deserialize" do

    it 'reconstructs record from value produced by #serialize' do
      str = record.serialize
      clone = Thales::Datamodel::Cornerstone::Record.new(str)
      clone.deserialize(str)
      clone.should == record
    end
  end

end

#EOF
