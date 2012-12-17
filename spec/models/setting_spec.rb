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

    it 'forcing reload from database' do
      # Change values, but do not save them to database
      s1 = Setting.instance
      s1.should_not be_nil
      s1.oaipmh_repositoryName = 'a1'
      s1.oaipmh_adminEmail = 'b1'
      s1.rifcs_group = 'c1'
      s1.rifcs_originatingSource = 'd1'
      s1.save

      # Values are there (without reload from database)
      s2 = Setting.instance(true)
      s2.should_not be_nil
      s2.oaipmh_repositoryName.should == 'a1'
      s2.oaipmh_adminEmail.should == 'b1'
      s2.rifcs_group.should == 'c1'
      s2.rifcs_originatingSource.should == 'd1'

      # Values are there (with reload from database)
      s3 = Setting.instance(true)
      s3.should_not be_nil
      s3.oaipmh_repositoryName.should == 'a1'
      s3.oaipmh_adminEmail.should == 'b1'
      s3.rifcs_group.should == 'c1'
      s3.rifcs_originatingSource.should == 'd1'

      # Change values, but DO NOT save them to database
      s4 = Setting.instance
      s4.should_not be_nil
      s4.oaipmh_repositoryName = 'a2'
      s4.oaipmh_adminEmail = 'b2'
      s4.rifcs_group = 'c2'
      s4.rifcs_originatingSource = 'd2'

      # New values are in the cached copy
      s5 = Setting.instance
      s5.should_not be_nil
      s5.oaipmh_repositoryName.should == 'a2'
      s5.oaipmh_adminEmail.should == 'b2'
      s5.rifcs_group.should == 'c2'
      s5.rifcs_originatingSource.should == 'd2'

      # New values are not there (when reloaded from database)
      s6 = Setting.instance(true)
      s6.should_not be_nil
      s6.oaipmh_repositoryName.should == 'a1'
      s6.oaipmh_adminEmail.should == 'b1'
      s6.rifcs_group.should == 'c1'
      s6.rifcs_originatingSource.should == 'd1'
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
