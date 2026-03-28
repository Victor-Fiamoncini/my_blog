Rails.application.routes.draw do
  root "posts#index"

  get    "posts/:slug", to: "posts#show", as: :post
  get    "login",       to: "sessions#new",     as: :login
  post   "login",       to: "sessions#create"
  delete "logout",      to: "sessions#destroy", as: :logout

  namespace :dashboard do
    root "posts#index"
    resources :posts, except: [ :show ] do
      member { patch :toggle_published }
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  if Rails.env.test?
    get "test/login/:user_id", to: "test/sessions#create", as: :test_login
  end
end
