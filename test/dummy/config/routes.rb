Rails.application.routes.draw do
  devise_for :users
  resources :test_models
  root to: 'test_models#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
