# Ruby on Rails model

class Setting < ActiveRecord::Base
  attr_accessible :oaipmh_repositoryName
  attr_accessible :oaipmh_adminEmail
  attr_accessible :rifcs_group
  attr_accessible :rifcs_originatingSource

  # The singletonGuard column must always be set to "0" to
  # ensure that only one row is created in the database table.

  validates_inclusion_of :singletonGuard, :in => [0]

  DEFAULT_OAIPMH_REPOSITORYNAME = 'Thales'
  DEFAULT_OAIPMH_ADMINEMAIL = 'example@example.com'
  DEFAULT_RIFCS_GROUP = 'Thales'
  DEFAULT_RIFCS_ORIGINATINGSOURCE = 'Thales'

  # Reset to system defaults

  def self.reset
    s = find(:first)
    if s
      s.destroy
    end
  end

  # Retrieve the settings

  def self.instance
    find(:first) || create_default
  end

  private
  def self.create_default
    row = Setting.new

    row.oaipmh_repositoryName = DEFAULT_OAIPMH_REPOSITORYNAME
    row.oaipmh_adminEmail = DEFAULT_OAIPMH_ADMINEMAIL
    row.rifcs_group = DEFAULT_RIFCS_GROUP
    row.rifcs_originatingSource = DEFAULT_RIFCS_ORIGINATINGSOURCE
    row.singletonGuard = 0 # ensures there is only one instance

    row.save!
    return row
  end

end
