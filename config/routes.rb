Rails.application.routes.draw do
  # API routes (for mobile)
  namespace :api do
    namespace :v1 do
      post 'auth/register', to: 'auth#register'
      post 'auth/login',    to: 'auth#login'
      get  'auth/me',       to: 'auth#me'
      put  'auth/me',       to: 'auth#update_profile'

      resources :owners, only: [:index, :create, :show, :update]

      resources :buildings, only: [:index, :create, :show, :update] do
        resources :apartments, only: [:index, :create]
        resources :publications, only: [:index, :create]
      end

      resources :apartments, only: [:show, :update, :destroy] do
        post :assign_tenant, on: :member
        resources :payments, only: [:index, :create]
        resources :incidents, only: [:index, :create]
      end

      resources :payments, only: [:show] do
        post :validate, on: :member
      end
      resources :incidents, only: [:show, :update]
      resources :publications, only: [:show] do
        post :like, on: :member
        resources :comments, only: [:index, :create]
      end
      resources :move_out_notices, only: [:create]
      resources :providers, only: [:index, :create, :update, :destroy]
      resources :tenants, only: [] do
        put :rating, on: :member
        post :cash_payment, on: :member
      end

      post 'apartments/:id/unassign_tenant', to: 'apartments#unassign_tenant'

      get 'annonces', to: 'annonces#index'
      get 'annonces/:id', to: 'annonces#show'
      get 'feed',             to: 'publications#agent_feed'
      get 'feed/owner',       to: 'publications#owner_feed'

      get 'dashboard', to: 'dashboard#index'
      get 'dashboard/admin', to: 'dashboard#admin'
      get 'dashboard/tenant', to: 'dashboard#tenant'
      get 'dashboard/owner', to: 'dashboard#owner'
    end
  end

  # Web routes (for desktop)
  root 'web/annonces#index'

  get  'login',     to: 'web/sessions#new'
  post 'login',     to: 'web/sessions#create'
  get  'pro/login', to: 'web/pro/sessions#new'
  post 'pro/login', to: 'web/pro/sessions#create'
  get  'logout',    to: 'web/sessions#destroy'

  get  'register',  to: 'web/registrations#new'
  post 'register',  to: 'web/registrations#create'

  get  'annonces',      to: 'web/annonces#index'
  get  'annonces/:id',  to: 'web/annonces#show', as: :annonce

  get  'dashboard',         to: 'web/dashboard#index'
  get  'dashboard/admin',   to: 'web/dashboard#admin'
  get  'dashboard/tenant',  to: 'web/dashboard#tenant'
  get  'dashboard/owner',   to: 'web/dashboard#owner'

  get  'agent/feed',        to: 'web/publications#agent_index'
  get  'agent/incidents',   to: 'web/incidents#agent_index'
  get  'agent/paiements',   to: 'web/payments#agency_index', as: :agent_payments
  get  'mes-signalements',  to: 'web/incidents#tenant_index', as: :tenant_incidents

  get  'admin/agencies',    to: 'web/admin/agencies#index'
  get  'admin/users',       to: 'web/admin/users#index'

  resources :buildings, controller: 'web/buildings' do
    resources :apartments, controller: 'web/apartments', only: [:index, :new, :create]
    resources :publications, controller: 'web/publications', only: [:index, :create]
  end

  resources :apartments, controller: 'web/apartments', only: [:show, :edit, :update] do
    post 'assign_tenant',   on: :member
    post 'unassign_tenant', on: :member
    resources :payments, controller: 'web/payments', only: [:index, :new, :create]
    resources :incidents, controller: 'web/incidents', only: [:index, :new, :create]
  end

  get  'payments/pending_validation', to: 'web/payments#pending_validation', as: :pending_validation_payments
  post 'payments/:id/validate',        to: 'web/payments#validate',            as: :validate_payment
  resources :payments, controller: 'web/payments', only: [:show]
  resources :incidents, controller: 'web/incidents', only: [:show, :update]
  resources :providers, controller: 'web/providers'

  resources :publications, controller: 'web/publications', only: [:show] do
    post :like, on: :member
    resources :comments, controller: 'web/comments', only: [:create]
  end
  resources :move_out_notices, controller: 'web/move_out_notices', only: [:new, :create]

  resources :owners, controller: 'web/owners', only: [:index, :new, :create, :edit, :update]
  resources :tenants, controller: 'web/tenants', only: [:show] do
    put :rating, on: :member
    post :cash_payment, on: :member
  end

  get  'profil',      to: 'web/profiles#show', as: :profile
  get  'profil/edit', to: 'web/profiles#edit', as: :edit_profile
  patch 'profil',     to: 'web/profiles#update'
end
