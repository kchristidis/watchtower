class SensorAccessSerializer < ActiveModel::Serializer
  attributes :id, :sensor_id, :module_id, :user_id
end
