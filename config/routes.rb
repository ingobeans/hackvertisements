Rails.application.routes.draw do
  resources :hackvertisements
  get "up" => "rails/health#show", as: :rails_health_check

  get '/auth/delete', to: 'sessions#delete'
  get '/auth/:provider/callback', to: 'sessions#create'
  
  root "home#index"
end
