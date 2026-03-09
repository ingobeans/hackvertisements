Rails.application.routes.draw do
  resources :hackvertisements
  get "up" => "rails/health#show", as: :rails_health_check

  get '/auth/:provider/callback', to: 'sessions#create'
  get '/login', to: 'sessions#new'
  
  root "home#index"
end
