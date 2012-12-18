require 'spec_helper'

describe SettingsController do

  AUTHENTICATED_USER_ID = 42

  before(:each) do
    # Create a user so authentication succeeds
    user = User.new
    user.id = AUTHENTICATED_USER_ID
    user.givenname = 'test'
    user.surname = 'test'
    user.uuid = 'urn:uuid:00000000-0000-0000-0000-000000000000'
    user.auth_type = Thales::Authentication::Password::AUTH_TYPE
    user.auth_name = 'user1'
    user.save
  end

  # This should return the minimal set of attributes required to create a valid
  # Setting. As you add validations to Setting, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      "oaipmh_repositoryName" => "test repositoryName",
      "oaipmh_adminEmail" => "test-email@example.com",
      "rifcs_group" => "test group",
      "rifcs_originatingSource" => "test originatingSource",
    }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # SettingsController. Be sure to keep this updated too.
  def valid_session
    {
      :user_id => AUTHENTICATED_USER_ID,
    }
  end

  describe "GET index" do
    it "assigns all settings as @settings" do
      #setting = Setting.create! valid_attributes
      inst = Setting.instance
      get :index, {}, valid_session
      assigns(:settings).should eq(inst)
    end
  end

  describe "GET edit" do
    it "assigns the requested setting as @setting" do
      #setting = Setting.create! valid_attributes
      inst = Setting.instance
      get :edit, {:id => 1}, valid_session
      assigns(:setting).should eq(inst)
    end
  end

#  describe "PUT update" do
#    describe "with valid params" do
#      it "updates the requested setting" do
#        setting = Setting.create! valid_attributes
#        # Assuming there are no other settings in the database, this
#        # specifies that the Setting created on the previous line
#        # receives the :update_attributes message with whatever params are
#        # submitted in the request.
#        Setting.any_instance.should_receive(:update_attributes).with({ "oaipmh_email" => "MyString" })
#        put :update, {:id => setting.to_param, :setting => { "oaipmh_email" => "MyString" }}, valid_session
#      end
#
#      it "assigns the requested setting as @setting" do
#        setting = Setting.create! valid_attributes
#        put :update, {:id => setting.to_param, :setting => valid_attributes}, valid_session
#        assigns(:setting).should eq(setting)
#      end
#
#      it "redirects to the setting" do
#        setting = Setting.create! valid_attributes
#        put :update, {:id => setting.to_param, :setting => valid_attributes}, valid_session
#        response.should redirect_to(setting)
#      end
#    end
#
#    describe "with invalid params" do
#      it "assigns the setting as @setting" do
#        setting = Setting.create! valid_attributes
#        # Trigger the behavior that occurs when invalid params are submitted
#        Setting.any_instance.stub(:save).and_return(false)
#        put :update, {:id => setting.to_param, :setting => { "oaipmh_email" => "invalid value" }}, valid_session
#        assigns(:setting).should eq(setting)
#      end
#
#      it "re-renders the 'edit' template" do
#        setting = Setting.create! valid_attributes
#        # Trigger the behavior that occurs when invalid params are submitted
#        Setting.any_instance.stub(:save).and_return(false)
#        put :update, {:id => setting.to_param, :setting => { "oaipmh_email" => "invalid value" }}, valid_session
#        response.should render_template("edit")
#      end
#    end
#  end

end
