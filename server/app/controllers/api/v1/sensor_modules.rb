module API
  module V1
    class SensorModules < Grape::API
      include API::V1::Defaults
      resource :sensor_modules do
        desc "Get sensor_modules by sensor_module_id"
        params do
          optional :sensor_module_id
        end
        get :index do
          current_user.sensor_modules
            .where("(sensor_modules.id = ? OR ?)", params[:sensor_module_id], params[:sensor_module_id].nil?)
        end
      end
    end
  end
end
