Rails.application.routes.draw do

  resources :deployment, only: [:index, :create]

  root to: 'deployment#index'

end
