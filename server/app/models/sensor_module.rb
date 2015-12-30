class SensorModule < ActiveRecord::Base
  belongs_to :user
  has_many :sensors

  has_many :sensor_module_accesses
  has_many :accessors, through: :sensor_module_accesses

  has_many :data_points, through: :sensors
end
