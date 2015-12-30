json.array!(@sensor_accesses) do |sensor_access|
  json.extract! sensor_access, :id, :sensor_id, :module_id, :user_id
  json.url sensor_access_url(sensor_access, format: :json)
end
