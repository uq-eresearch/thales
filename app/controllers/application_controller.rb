class ApplicationController < ActionController::Base
  protect_from_forgery

  protected
  # Returns current username, or nil if not logged in
  def current_user
    if session[:user_id]
      @current_user ||= User.find_by_id(session[:user_id])
    else
      return nil
    end
  end

  # Make available to templates as a helper method
  helper_method :current_user


  def authenticate
    logged_in? ? true : access_denied
  end

  # Test if logged in or not
  def logged_in?
    ! current_user.nil?
  end

  helper_method :logged_in?


  def access_denied
    redirect_to login_path, :notice => 'Please log in to continue'
    false
  end

end
