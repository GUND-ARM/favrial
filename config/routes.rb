Rails.application.routes.draw do
  resources :credentials
  resources :tweets

  get '/auth/:provider/callback', to: 'credentials#create'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
