class SessionsController < ApplicationController
  def new
  end

  def create
    if u = User.login(params[:username], params[:password])
      login_with_session(u)
      flash[:success] = 'Login successful'
    else
      flash[:warning] = 'Login failed!'
    end
    redirect_to :root
  end

  def destroy
    logout
    flash[:info] = 'Logged out'
    redirect_to :root
  end

  private

  def action_allowed?(args = params)
    case args[:action]
    when 'new', 'create'
      @error_message = 'Already logged in.'
      !current_user
    when 'destroy'
      true
    end
  end
end

