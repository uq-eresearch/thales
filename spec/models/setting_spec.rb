# RSpec

require 'spec_helper'

describe Setting do
  before(:each) do
    Setting.reset
  end

  describe '#instance' do

    it 'initialized with default values' do
      s = Setting.instance

      s.should_not be_nil
      s.oaipmh_repositoryName.should == Setting::DEFAULT_OAIPMH_REPOSITORYNAME
      s.oaipmh_adminEmail.should == Setting::DEFAULT_OAIPMH_ADMINEMAIL
      s.rifcs_group.should == Setting::DEFAULT_RIFCS_GROUP
      s.rifcs_originatingSource.should == Setting::DEFAULT_RIFCS_ORIGINATINGSOURCE
    end

    it 'can store and retrieve values' do
      # Save new values
      s1 = Setting.instance
      s1.should_not be_nil
      s1.oaipmh_repositoryName = 'aaa'
      s1.oaipmh_adminEmail = 'bbb'
      s1.rifcs_group = 'ccc'
      s1.rifcs_originatingSource = 'ddd'
      s1.save

      # Check if new values are there
      s2 = Setting.instance
      s2.should_not be_nil
      s2.oaipmh_repositoryName.should == 'aaa'
      s2.oaipmh_adminEmail.should == 'bbb'
      s2.rifcs_group.should == 'ccc'
      s2.rifcs_originatingSource.should == 'ddd'
    end

  end

  describe '#reset' do

    it 'sets values to defaults' do
      # Save new values
      s1 = Setting.instance
      s1.should_not be_nil
      s1.oaipmh_repositoryName = 'AAA'
      s1.oaipmh_adminEmail = 'BBB'
      s1.rifcs_group = 'CCC'
      s1.rifcs_originatingSource = 'DDD'
      s1.save

      # Check if new values are there
      s2 = Setting.instance
      s2.should_not be_nil
      s2.oaipmh_repositoryName.should == 'AAA'
      s2.oaipmh_adminEmail.should == 'BBB'
      s2.rifcs_group.should == 'CCC'
      s2.rifcs_originatingSource.should == 'DDD'

      # Reset sets it back to defaults
      Setting.reset
      s4 = Setting.instance
      s4.should_not be_nil
      s4.oaipmh_repositoryName.should == Setting::DEFAULT_OAIPMH_REPOSITORYNAME
      s4.oaipmh_adminEmail.should == Setting::DEFAULT_OAIPMH_ADMINEMAIL
      s4.rifcs_group.should == Setting::DEFAULT_RIFCS_GROUP
      s4.rifcs_originatingSource.should == Setting::DEFAULT_RIFCS_ORIGINATINGSOURCE
    end

  end
end
