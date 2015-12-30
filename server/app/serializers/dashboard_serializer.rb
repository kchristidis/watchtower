class DashboardSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :config, :name
end
