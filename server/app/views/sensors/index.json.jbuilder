json.array!(@sensors) do |sensor|
  json.extract! sensor, :id, :name, :sensor_module_id
  json.url sensor_url(sensor, format: :json)
end
