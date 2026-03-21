Rails.application.routes.draw do
  get '/gallery', to: 'home#gallery'
  resources :hackvertisements
  get "up" => "rails/health#show", as: :rails_health_check

  get '/auth/dev', to: 'sessions#dev'
  get '/auth/delete', to: 'sessions#delete'
  get '/auth/:provider/callback', to: 'sessions#create'

  get '/dashboard', to: 'home#dashboard'
  get '/serve', to: 'home#serve'

  get '/leaderboard', to: 'leaderboard#index'
  
  root "home#index"
end
