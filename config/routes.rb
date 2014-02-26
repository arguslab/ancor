Ancor::Application.routes.draw do

  namespace(:v1, defaults: { format: :json }) do
    # General API resources
    post "plan" => "engine#plan"
    post "deploy" => "engine#deploy"

    resources :instances, except: [:new, :edit]

    # Webhooks and special resources
    # TODO Fold hiera into instance resource
    get "hiera/:certname" => "hiera#show"
    post "webhook/mcollective"
    post "webhook/puppet"

    root to: "home#index"
  end

  mount Sidekiq::Web => "/sidekiq"

end
