Orcid::Engine.routes.draw do
  scope module: 'orcid' do
    resource :profile_request, only: [:show, :new, :create, :destroy]
    resources :profile_connections, only: [:new, :create, :index]

    get 'create_orcid', to: 'create_profile#create'
    get "disconnect", to: "profile_connections#destroy"
  end
end
