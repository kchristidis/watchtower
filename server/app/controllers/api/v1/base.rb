module API
  module V1
    class Base < Grape::API
      helpers do
        def authenticate!
          error!('Unauthorized. Invalid or expired token.', 401) unless current_user
        end

        def current_user
          # find token. Check if valid.
          token = ApiKey.where(access_token: params[:token]).first
          if token && !token.expired?
            @current_user ||= User.find(token.user_id)
          else
            @current_user ||= User.find_by(id: env['rack.session'][:user_id])
          end
        end
      end

      mount API::V1::Auth
      mount API::V1::Users
      mount API::V1::Sensors
      mount API::V1::SensorModules
      mount API::V1::DataPoints

      add_swagger_documentation(
        api_version: "v1",
        hide_documentation_path: true,
        mount_path: "/api/v1/doc",
        hide_format: true
      )
    end
  end
end
