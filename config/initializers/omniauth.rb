# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :cas, name: 'cas',
                 url: ENV.fetch('CAS_BASE_URL') { 'https://thekey.me/cas' },
                 disable_ssl_verification: true
end
