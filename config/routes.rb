Rails.application.routes.draw do
  require 'sidekiq/web'
  require 'sidetiq/web'

  Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
    [user, password] == [ENV['SIDEKIQ_USERNAME'], ENV['SIDEKIQ_PASSWORD']]
  end

  mount Sidekiq::Web => '/sidekiq'

  # Serve websocket cable requests in-process
  mount ActionCable.server => '/cable'

  devise_for :users, :controllers => { omniauth_callbacks: 'omniauth_callbacks' }

  # if routing the root path, update for your controller
  root to: 'pages#show', id: 'home'
  get 'users/index'
  get "facebookmessages/facebookmessages"
  # match '/users/:id/finish_signup' => 'users#finish_signup', via: [:get, :patch], :as => :finish_signup

  resources :dashboard, only: [:index]

  namespace :api do
    namespace :v1, defaults: { format: 'json' } do
      # Testing endpoint for authentication
      get '/test' => 'base#test' if Rails.env.test?
      post '/token' => 'base#token'

      mount_devise_token_auth_for 'User', at: 'auth', controllers: {
        sessions: 'api/v1/sessions',
      }

      resources :promotional_tweets, only: [:index, :create]
      resources :subscriptions, only: [:create, :update] do
        post '/cancel' => 'subscriptions#cancel', on: :member
      end
      resources :subscription_plans, only: [:index]
      resources :invoices, only: [:index]
      resources :listen_signals, only: [:index, :show, :create, :update, :destroy] do
        get :templates, on: :collection
      end
      resources :users, only: [] do
        get '/me' => 'users#show', on: :collection
        post :update, on: :member
      end
      resources :brands, only: [:destroy] do
        get '/me' => 'brands#show', on: :collection
        get '/account_plans' => 'brands#account_plans', on: :collection
        post '/account_info' => 'brands#update_account_info', on: :collection
      end
    end
  end

  namespace :webhooks do
    namespace :stripe, defaults: { format: 'json' } do
      post '/' => 'base#index'
    end
  end

  get 'subscription_plans' => 'dashboard#index', as: :subscription_plans
  get 'finish_setup' => 'dashboard#index', as: :finish_setup

  # Catch all for any routes nested with `/dashboard`. Any non-existant routes will be handled by the React app.
  get 'dashboard/*other' => 'dashboard#index'

  # Catch all for High Voltage static page thingy
  get "/*id" => 'pages#show', as: :page, format: false
end
