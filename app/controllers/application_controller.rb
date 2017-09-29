# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def authenticate_active_admin_user!
    redirect_to user_cas_omniauth_authorize_path and return unless current_user
    render plain: 'You are not an admin.', status: :unauthorized unless current_user.has_access
    # redirect_to unauthorized_path unless current_user.has_access
  end

  def unauthorized
    render plain: 'You are not an admin.', status: :unauthorized
  end

  def after_sign_out_path_for(_resource_or_scope)
    "#{ENV['CAS_BASE_URL']}/logout"
  end
end
