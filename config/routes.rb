Rails.application.routes.draw do
  resources :users
  root "tweets#index"
  resources :tweets
  resources :sessions

  get '/auth/:provider/callback', to: 'sessions#create'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
