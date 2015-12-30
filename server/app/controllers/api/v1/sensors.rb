module API
  module V1
    class Sensors < Grape::API
      include API::V1::Defaults

      resource :sensors do
        desc "Get sensors by sensor_module_id or sensor_id"
        params do
          optional :sensor_module_id
          optional :sensor_id
        end
        get :index do
          current_user.sensors
            .where("(sensors.id = ? OR ?)", params[:sensor_id], params[:sensor_id].nil?)
            .where("(sensor_module_id = ? OR ?)", params[:sensor_module_id], params[:sensor_module_id].nil?)
        end
      end
    end
  end
end
