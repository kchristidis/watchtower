class User < ActiveRecord::Base
  has_secure_password

  has_many :dashboards

  has_many :sensor_modules
  has_many :sensor_module_accesses
  has_many :accessible_sensor_modules, through: :sensor_module_accesses, source: :sensor_module

  has_many :sensors, through: :sensor_modules
  has_many :sensor_accesses
  has_many :accessible_sensors, through: :sensor_accesses, source: :sensor
  has_many :accessible_sensor_modules, through: :sensor_module_accesses, source: :sensor_module

  has_many :data_points, through: :sensor_modules

  validates :username,
    presence: true,
    uniqueness: true
  validates :password, unless: 'password.blank?',
    format: {
    with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*(_|[^\w]|\d)).+\z/,
    message: 'must meet the security requirements (upper and lower case, and special characters)'
  },
  length: { minimum: 6 }

  def all_sensor_ids
    all_sensors.flat_map(&:id)
  end

  def all_sensors
    (sensors +
     sensor_modules.flat_map(&:sensors) +
     accessible_sensors +
     accessible_sensor_modules.flat_map(&:sensors)).uniq
  end

  def user
    self
  end

  def self.login(username, password)
    User.find_by(username: username).try(:authenticate, password)
  end
end
