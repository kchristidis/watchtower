class DataPointSerializer < ActiveModel::Serializer
  attributes :id, :sensor_id, :data, :timestamp
end
