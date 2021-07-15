Rails.application.config.middleware.use OmniAuth::Builder do
  settings = {
    client_options: {
      site: ENV["OKTA_ISSUER"],
      authorize_url: "#{ENV["OKTA_ISSUER"]}/v1/authorize",
      token_url: "#{ENV["OKTA_ISSUER"]}/v1/token"
    },
    issuer: ENV["OKTA_ISSUER"],
    redirect_uri: ENV["OKTA_REDIRECT_URI"],
    auth_server_id: ENV["OKTA_AUTH_SERVER_ID"],
    scope: "openid profile email"
  }
  Rails.logger.info("using okta settings: #{settings.inspect}")

  provider :oktaoauth, ENV["OKTA_CLIENT_ID"], ENV["OKTA_CLIENT_SECRET"], settings
end
