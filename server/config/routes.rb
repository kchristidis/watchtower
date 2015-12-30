Rails.application.routes.draw do
  resources :dashboards

  resources :sensor_modules, shallow: true do
    resources :data_points, only: [:index]
    resources :sensor_module_accesses
    resources :sensors do
      resources :data_points, only: [:index]
      resources :sensor_accesses
    end
  end
  resources :sessions
  resources :users, shallow: true do
    resources :dashboards
    resources :data_points, only: [:index]
  end
  resource :pages

  match 'welcome', to: 'pages#welcome', via: :get, as: 'welcome'

  match 'login' => 'sessions#new', via: :get, as: :login
  match 'logout' => 'sessions#destroy', via: :get, as: :logout

  # API+API Documentation
  mount API::Base, at: '/'
  mount GrapeSwaggerRails::Engine => '/apidoc'

  root 'page#welcome'
end
