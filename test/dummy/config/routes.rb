Rails.application.routes.draw do
  resources :grand_test_models
  resources :great_test_models
  resources :nested_test_models
  devise_for :users
  resources :test_models
  root to: 'test_models#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
