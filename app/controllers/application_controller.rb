# frozen_string_literal: true

class ApplicationController < ActionController::Base
  def authenticate_active_admin_user!
    redirect_to("/login/new") && return unless current_user
    unauthorized unless current_user.has_access
  end

  def unauthorized
    render plain: "Permission Denied. Contact help@cru.org to request access.", status: :unauthorized
  end

  def after_sign_out_path_for(_resource_or_scope)
    "#{ENV.fetch("OKTA_ISSUER")}/v1/logout?id_token_hint=#{session[:id_token]}&post_logout_redirect_uri=#{request.base_url}"
  end
end
