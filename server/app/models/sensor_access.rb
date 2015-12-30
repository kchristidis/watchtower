class SensorAccess < ActiveRecord::Base
  belongs_to :sensor
  belongs_to :accessor, class_name: 'User'
  delegate :sensor_module, to: :sensor
end
