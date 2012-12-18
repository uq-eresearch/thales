require 'spec_helper'

describe "settings/edit" do
  before(:each) do
    @settings = assign(:setting, stub_model(Setting,
      :oaipmh_repositoryName => "test repositoryName",
      :oaipmh_adminEmail => "test-email@example.com",
      :rifcs_group => "test group",
      :rifcs_originatingSource => "test originatingSource",
    ))
  end

  it "renders the edit setting form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => settings_path(@setting), :method => "post" do

      assert_select 'input#setting_oaipmh_repositoryName' do |elements|
        elements.each do |e|
          e['name'].should == 'setting[oaipmh_repositoryName]'
          e['value'].should == 'test repositoryName'
        end
      end

      assert_select 'input#setting_oaipmh_adminEmail' do |elements|
        elements.each do |e|
          e['name'].should == 'setting[oaipmh_adminEmail]'
          e['value'].should == 'test-email@example.com'
        end
      end

      assert_select 'input#setting_rifcs_group' do |elements|
        elements.each do |e|
          e['name'].should == 'setting[rifcs_group]'
          e['value'].should == 'test group'
        end
      end

      assert_select 'input#setting_rifcs_originatingSource' do |elements|
        elements.each do |e|
          e['name'].should == 'setting[rifcs_originatingSource]'
          e['value'].should == 'test originatingSource'
        end
      end

    end
  end
end
