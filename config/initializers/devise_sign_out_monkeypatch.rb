# This monkey patch modifies the redirect to allow it to redirect to a different host on log out.

Rails.application.config.to_prepare do
  class Devise::SessionsController < DeviseController # rubocop:disable Lint/ConstantDefinitionInBlock
    def respond_to_on_destroy
      # We actually need to hardcode this as Rails default responder doesn't
      # support returning empty response on GET request
      respond_to do |format|
        format.all { head :no_content }
        format.any(*navigational_formats) { redirect_to after_sign_out_path_for(resource_name), status: Devise.responder.redirect_status, allow_other_host: true }
      end
    end
  end
end
