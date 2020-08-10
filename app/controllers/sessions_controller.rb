# frozen_string_literal: true

class SessionsController < Devise::OmniauthCallbacksController
  def oktaoauth
    @user = User.find_or_create_from_auth_hash(auth_hash)
    sign_in @user
    session[:id_token] = request.env.dig("omniauth.auth", "extra", "id_token")
    redirect_to admin_forms_path
  end

  protected

  def auth_hash
    request.env["omniauth.auth"]
  end
end
