Rails.application.routes.draw do
  root 'projects#dashboard'

  devise_for :users, controllers: { sessions: 'sessions', passwords: 'passwords' }

  get 'hosts/search', to: 'hosts#search'
  resources :hosts
  resources :recipes

  resources :projects do
    resources :project_configurations

    resources :stages do
      member do
        get 'capfile'
        match 'recipes', via: :all
        get 'tasks'
        post 'clone'
      end
      resources :stage_configurations
      resources :roles
      resources :deployments do
        get 'latest', on: :collection
        post 'cancel', on: :member
        get 'status', on: :member
      end
    end
  end

  # RESTful auth
  resources :users do
    member do
      get :deployments
      post :enable
    end
  end
  get 'user/:login/reset_password', to: 'users#reset_password', as: 'reset_password'

  # match ':controller/:action', via: :all
  # match ':controller/:action/:id', via: :all
end
