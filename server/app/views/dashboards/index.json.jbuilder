json.array!(@dashboards) do |dashboard|
  json.extract! dashboard, :id, :user_id, :config, :name
  json.url dashboard_url(dashboard, format: :json)
end
