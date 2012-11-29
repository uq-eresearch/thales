# RSpec

require 'thales/datamodel/cornerstone'

describe Thales::Datamodel::Cornerstone::PropertyLink do
  let(:example_without_hint) {
    Thales::Datamodel::Cornerstone::PropertyLink.new('http://without.example.com') }
  let(:example_with_hint) {
    Thales::Datamodel::Cornerstone::PropertyLink.new('http://with.example.com', 'example hint') }

  describe "#uri" do
    it 'initialized by constructor' do
      example_without_hint.uri.should == 'http://without.example.com'
      example_with_hint.uri.should == 'http://with.example.com'
    end
  end

  describe "#hint" do
    it 'initializes without hint' do
      example_without_hint.hint.should be_nil
    end

    it 'initializes with hint' do
      example_with_hint.hint.should == 'example hint'
    end
  end

  describe "#to_s" do
    it 'has string value without hint' do
      example_without_hint.to_s.should == 'http://without.example.com'
    end

    it 'has string value with hint' do
      example_with_hint.to_s.should == 'http://with.example.com example hint'
    end
  end

end
    
#EOF
