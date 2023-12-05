require "sidekiq/pro/web"

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "admin/forms#index"

  devise_for :users, class_name: "User", controllers: {omniauth_callbacks: "sessions"}
  ActiveAdmin.routes(self)
  devise_scope :user do
    get "users/sign_out", to: "devise/sessions#destroy", as: :destroy_user_session
  end

  authenticate :user, lambda { |user| user.has_access } do
    mount Sidekiq::Web => "/sidekiq"
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :forms, only: %i[show create]

  get "monitors/lb"
  get "/login/new", to: "login#new"
  get "/assets/campaign-form.js", to: redirect("/assets/custom/campaign-form.js")
  get "/packs/campaign.js", to: redirect("/assets/custom/campaign-form.js")
end
