# frozen_string_literal: true

Rails.application.routes.draw do
  # devise_for :users, ActiveAdmin::Devise.config
  devise_for :users, class_name: 'User', controllers: { omniauth_callbacks: 'sessions' }
  ActiveAdmin.routes(self)
  devise_scope :user do
    get 'users/sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :forms, only: %i[show create]

  get 'monitors/lb'
  root 'admin/forms#index'
end
