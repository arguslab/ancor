Ancor::Application.routes.draw do

  namespace(:v1, defaults: { format: :json }) do
    # General API resources
    resources :environments, except: [:new, :edit] do
      post "plan"
    end

    resources :instances, except: [:new, :edit]
    resources :goals, only: [:index]
    resources :roles, only: [:index]
    resources :tasks, only: [:index]

    # Webhooks and special resources
    # TODO Fold hiera into instance resource
    get "hiera/:certname" => "hiera#show"
    post "webhook/mcollective"
    post "webhook/puppet"

    root to: "home#index"
  end

  mount Sidekiq::Web => "/sidekiq"

end
