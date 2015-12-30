module API
  module V1
    class DataPoints < Grape::API
      include API::V1::Defaults

      resource :data_points do
        desc "Get data points by limit and offset and/or by timestamp range"
        params do
          requires :token, type: String, desc: "Access token."
          optional :limit
          optional :offset
          optional :timestamp_from
          optional :timestamp_to
          optional :sensor_module_id
          optional :sensor_id
        end
        get :index do
          authenticate!
          from = DateTime.parse(
            params[:timestamp_from] || (DateTime.now - 24.hours).to_s)
          to = DateTime.parse(
            params[:timestamp_to] || DateTime.now.to_s)
          DataPoint
            .joins(:sensor)
            .order(:timestamp)
            .where(sensor_id: current_user.all_sensor_ids)
            .where("(sensor_id = ? OR ?)", params[:sensor_id], params[:sensor_id].nil?)
            .where("(sensor_module_id = ? OR ?)", params[:sensor_module_id], params[:sensor_module_id].nil?)
            .where("timestamp < ? AND timestamp > ?", to, from)
            .limit(params[:limit] || 100)
            .offset(params[:offset] || 0)
        end
      end
    end
  end
end
