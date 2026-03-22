Rails.application.routes.draw do
  get '/gallery', to: 'home#gallery'
  resources :hackvertisements

  get '/api/fetch', to: 'api#fetch'
  get '/api/fetch_url', to: 'api#fetch_url'
  get '/serve', to: 'api#serve'

  get "up" => "rails/health#show", as: :rails_health_check

  get '/auth/dev', to: 'sessions#dev'
  get '/auth/delete', to: 'sessions#delete'
  get '/auth/:provider/callback', to: 'sessions#create'

  get '/dashboard', to: 'home#dashboard'

  get '/leaderboard', to: 'leaderboard#index'
  
  root "home#index"
end
