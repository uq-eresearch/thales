require 'spec_helper'

describe "settings/index" do
  before(:each) do
    assign(:settings, 
      stub_model(Setting,
        :oaipmh_repositoryName => 'test repositoryName',
        :oaipmh_adminEmail => "test-email@example.com",
        :rifcs_group => "test group",
        :rifcs_originatingSource => "test originatingSource",
      )
    )
  end

  it "renders a list of settings" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "div>dl>dd", :text => "test repositoryName".to_s, :count => 1
    assert_select "div>dl>dd", :text => "test-email@example.com".to_s, :count => 1
    assert_select "div>dl>dd", :text => "test originatingSource".to_s, :count => 1
    assert_select "div>dl>dd", :text => "test group".to_s, :count => 1
  end
end
