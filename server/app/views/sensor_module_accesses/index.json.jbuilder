json.array!(@sensor_module_accesses) do |sensor_module_access|
  json.extract! sensor_module_access, :id, :sensor_module_id, :user_id
  json.url sensor_module_access_url(sensor_module_access, format: :json)
end
