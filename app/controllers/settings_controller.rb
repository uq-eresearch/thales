require 'thales/authentication/password'

# Ruby on Rails controller

class SettingsController < ApplicationController

  before_filter :authenticate

  # GET /settings
  # GET /settings.json
  def index
    @settings = Setting.instance

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @settings }
    end
  end

  # GET /settings/1/edit
  def edit
    @setting = Setting.instance
  end

  # PUT /settings/1
  # PUT /settings/1.json
  def update
    @setting = Setting.instance

    respond_to do |format|
      if @setting.update_attributes(params[:setting])
        format.html { redirect_to settings_path, notice: 'Setting was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @setting.errors, status: :unprocessable_entity }
      end
    end
  end

end
