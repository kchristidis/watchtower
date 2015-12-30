class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include SessionsHelper
  helper_method :current_user

  # Set up user authorization
  include AuthorizationHelper
  before_filter :authorize


  def last_page
    request.env['HTTP_REFERER'] || :root
  end
  helper_method :last_page

  def redirect_back
    redirect_to last_page
  end
end
