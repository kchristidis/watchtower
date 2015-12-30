class UsersController < ApplicationController
  def create
    @user = User.new(user_params)

    if @user.save
      flash[:success] = "The user was successfully created"
      login_with_session(@user)
      redirect_to :root
    else
      render :new
    end
  end

  def show
    set_user
  end

  def update
    set_user

    if @user.update(user_params)
      flash[:success] = 'User successfully updated'
      render :show
    else
      render :edit
    end
  end

  def destroy
    set_user
    @user.destroy
    flash[:info] = 'User deleted'
    redirect_to :root
  end

  def index
    @users = User.order :username
  end

  def new
    @user = User.new
  end

  def edit
    set_user
  end

  def delete
    set_user
  end

  private

  def set_user
    @user ||= User.find_by(id: params[:id]) || current_user
  end
  alias_method :user, :set_user

  def user_params
    params.require(:user).permit!
  end

  def action_allowed?(args = params)
    case args[:action]
    when 'show', 'edit', 'update', 'delete', 'destroy'
      current_user == user
    when 'new', 'create'
      true
    end
  end
end
