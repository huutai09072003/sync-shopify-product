require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  mount ShopifyApp::Engine, at: '/'
  mount ActionCable.server => '/cable'
  mount Sidekiq::Web => '/sidekiq'
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    secure_username = ENV.fetch('SIDEKIQ_USERNAME', 'admin')
    secure_password = ENV.fetch('SIDEKIQ_PASSWORD', 'password')

    ActiveSupport::SecurityUtils.secure_compare(
      Digest::SHA256.hexdigest(username),
      Digest::SHA256.hexdigest(secure_username)
    ) & ActiveSupport::SecurityUtils.secure_compare(
      Digest::SHA256.hexdigest(password),
      Digest::SHA256.hexdigest(secure_password)
    )
  end

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  resources :augmented_realities, only: [] do
    collection do
      post :upload_gltf_file
      post :upload_usdz_file
    end
  end

  namespace :admin do
    get 'impersonate/:shop_id', to: 'impersonate#show', as: :impersonate
  end

  # charge related
  resources :recurring_application_charges, only: [:new]
  get 'charge/shopify/callback' => 'recurring_application_charges#callback', as: :callback_recurring_application_charge

  # public JS widget
  get 'js/:client_id/load', to: "widgets#show", as: 'widget'
  get 'js/load', to: "widgets#show", as: 'widget_without_client_id'
  resources :events, only: [:new]

  get '/external_products/:id', to: 'external_products#show'

  # app
  get '/live_preview/a/:client_id', to: 'live_preview#app'
  get '/live_preview/ar/:client_id', to: 'live_preview#app_ar'

  # proxy
  get '/p/(:proxy_id)', to: 'proxy#show'

  # user admin panel
  resources :products, only: [] do
    collection do
      get '/redirect-from-shopify-admin', to: 'products#create'
    end
  end

  resources :product_searches, only: [:new]

  # test
  unless Rails.env.production?
    namespace :test_store do
      resources :products, only: [:show] # => /test_store/products/starry-night
    end
  end

  # direct uploads
  namespace :api do
    scope module: 'v1', path: 'v1' do
      resource :shop, only: [:show, :update] do
        collection do
          get :paid_in_good_standing
        end
      end
      resources :direct_uploads, only: [:create]
      resources :products do
        collection do
          post :bulk_activate
          post :bulk_deactivate
          post :toggle_bulk_use_parent_image
        end
      end
      resources :shopify_products, only: [:index, :show]
      resources :local_shopify_products, only: [:index, :show] do
        collection do
          get :most_viewed
        end
      end
      resources :local_shopify_collections, only: [:index]
      resources :local_shopify_vendors do
        collection do
          get :vendor_names
        end
      end
      resources :background_collections do
        member do
          patch :make_default
        end
        collection do
          post :add_new
        end
      end
      resources :product_images, only: [:show, :create, :update, :destroy]
      resource :shop_images, only: [:show, :create, :destroy]
      resources :plans, only: [:index]
      # charge related
      resources :recurring_application_charges, only: [:create]
    end
  end

  pages = %w(home privacy-policy)
  pages.each do |page|
    get page, to: 'pages#show'
  end

  react_scopes = [
    {
      path: '/',
      scope_as: 'react',
      controller: 'react',
      action: 'index'
    },
    {
      path: '/admin/impersonate/:shop_id',
      scope_as: 'react_admin_impersonate',
      controller: 'admin/impersonate',
      action: 'show'
    }
  ]

  react_scopes.each do |scope|
    scope "#{scope[:path]}", as: "#{scope[:scope_as]}" do
      resources :products, to: "#{scope[:controller]}##{scope[:action]}", only: [:index, :edit]
      resources :background_collections, to: "#{scope[:controller]}##{scope[:action]}", only: [:index, :edit, :new]
      resources :settings, to: "#{scope[:controller]}##{scope[:action]}", only: [:index]
      resources :help, to: "#{scope[:controller]}##{scope[:action]}", only: [:index]
      resources :changelog, to: "#{scope[:controller]}##{scope[:action]}", only: [:index]
      resources :subscription, to: "#{scope[:controller]}##{scope[:action]}", only: [:index]
    end
  end

  root to: 'react#index'
end
