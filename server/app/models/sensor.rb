class Sensor < ActiveRecord::Base
  belongs_to :sensor_module
  delegate :user, to: :sensor_module

  has_many :sensor_accesses
  has_many :accessors, through: :sensor_accesses

  has_many :data_points
end
