Rails.application.routes.draw do
  get '/hackvertisements/wipe', to: 'hackvertisements#wipe'
  resources :hackvertisements
  get "up" => "rails/health#show", as: :rails_health_check

  get '/auth/dev', to: 'sessions#dev'
  get '/auth/delete', to: 'sessions#delete'
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/wipe', to: 'sessions#wipe'

  get '/dashboard', to: 'home#dashboard'
  get '/serve', to: 'home#serve'
  
  root "home#index"
end
