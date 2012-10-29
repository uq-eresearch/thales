require 'thales/authentication/password'

class SessionsController < ApplicationController

  def create

    username = params[:username].strip
    password = params[:password]

    if username.blank?
      user = nil
    else
      user = Thales::Authentication::Password.authenticate(username, password)
    end

    if ! user.nil?
      session[:user_id] = user.id
      redirect_to records_path, :notice => "Logged in successfully"
    else
      flash.now[:alert] = "Invalid login/password combination"
      render :action => 'new'
    end
  end

  def destroy
    reset_session
    redirect_to records_path, :notice => "You have been successfully logged out."
  end

end
