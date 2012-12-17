# RSpec

require 'spec_helper'

describe Setting do

  describe 'instance' do

    TEST_REPOSITORYNAME = 'RSpec repository'
    TEST_OAIPMH_ADMINEMAIL = 'rspec_test@email.example.com'
    TEST_RIFCS_GROUP = 'RSpec Test Group'
    TEST_RIFCS_ORIGINATINGSOURCE = 'RSpec Test Source'

    it 'initialized with default values' do
      s = Setting.instance

      s.should_not be_nil
      s.oaipmh_repositoryName.should == Setting::DEFAULT_OAIPMH_REPOSITORYNAME
      s.oaipmh_adminEmail.should == Setting::DEFAULT_OAIPMH_ADMINEMAIL
      s.rifcs_group.should == Setting::DEFAULT_RIFCS_GROUP
      s.rifcs_originatingSource.should == Setting::DEFAULT_RIFCS_ORIGINATINGSOURCE
    end

    it 'can store and retrieve values' do
      s = Setting.instance

      s.should_not be_nil
      s.oaipmh_repositoryName = TEST_REPOSITORYNAME
      s.oaipmh_adminEmail = TEST_OAIPMH_ADMINEMAIL
      s.rifcs_group = TEST_RIFCS_GROUP
      s.rifcs_originatingSource = TEST_RIFCS_ORIGINATINGSOURCE

      s.save!

      # TODO

      s2 = Setting.instance

      s2.should_not be_nil
      s2.oaipmh_repositoryName.should == TEST_REPOSITORYNAME
      s2.oaipmh_adminEmail.should == TEST_OAIPMH_ADMINEMAIL
      s2.rifcs_group.should == TEST_RIFCS_GROUP
      s2.rifcs_originatingSource.should == TEST_RIFCS_ORIGINATINGSOURCE
    end

  end
end
