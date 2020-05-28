require "sidekiq/pro/web"

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
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
  root "admin/forms#index"
end
