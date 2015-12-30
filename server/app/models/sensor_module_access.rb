class SensorModuleAccess < ActiveRecord::Base
  belongs_to :sensor_module
  belongs_to :accessor, class_name: 'User'
end
