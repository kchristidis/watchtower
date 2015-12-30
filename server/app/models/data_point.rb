class DataPoint < ActiveRecord::Base
  belongs_to :sensor
  delegate :sensor_module, to: :sensor
  delegate :user, to: :sensor_module

  scope :of_user, ->(user) { where(sensor_id: user.all_sensor_ids) }
end
