Orcid::Engine.routes.draw do
  resource :profile_request, only: [:show, :new, :create]
  resources :profile_connections, only: [:new, :create, :index]
end
