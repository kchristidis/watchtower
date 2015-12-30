json.array!(@data_points) do |data_point|
  json.extract! data_point, :id, :sensor_id, :data
  json.url data_point_url(data_point, format: :json)
end
