require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  root "tweets#index"

  resources :users
  resources :tweets

  get '/welcome', to: 'welcome#index'
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/logout', to: 'sessions#destroy'

  mount Sidekiq::Web => '/sidekiq', constraints: lambda { |req|
    # FIXME: user.admin? で管理者かどうかを判断できるようにする
    req.session['user_id'].present? and req.session['user_id'] == 3
  }

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
