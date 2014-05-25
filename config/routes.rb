Webistrano::Application.routes.draw do
  root 'projects#dashboard'

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

  resources :sessions do
    get :version, on: :collection
  end

  get 'signup', to: 'users#new'
  get 'login', to: 'sessions#new'
  get 'logout', to: 'sessions#destroy'

  match ':controller/:action', via: :all
  match ':controller/:action/:id', via: :all
end
