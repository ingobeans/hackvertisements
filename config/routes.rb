Rails.application.routes.draw do
  resources :hackvertisements
  get "up" => "rails/health#show", as: :rails_health_check
  root "home#index"
end
