json.array!(@sensor_modules) do |sensor_module|
  json.extract! sensor_module, :id, :name, :location, :user_id
  json.url sensor_module_url(sensor_module, format: :json)
end
