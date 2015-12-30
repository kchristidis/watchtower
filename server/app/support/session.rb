class Session
  include ActiveModel::Model

  attr_accessor :username, :password

  def initialize(args = {})
    @username = args[:username]
    @password = args[:password]
  end

  def invalid_password?
    login_errors unless user.try :has_password?, password
  end

  def user
    User.with_username username
  end

  def valid_password?
    !invalid_password?
  end

  private

  def login_errors
    errors.add :user_account, 'is invalid.'
  end
end
