# frozen_string_literal: true

class ApplicationController < ActionController::Base
  def authenticate_active_admin_user!
    redirect_to("/login/new") && return unless current_user
    unauthorized unless current_user.has_access
  end

  def unauthorized
    render plain: "Permission Denied. Contact help@cru.org to request access.", status: :unauthorized
  end

  def after_sign_out_path_for(_resource_or_scope) # MK: this is a Devise thing
    "something/logout"
  end
end
