# frozen_string_literal: true

require Rails.root.join('config', 'initializers', 'redis').to_s

sidekiq_namespace = ['campaign-forms', Rails.env, 'sidekiq'].join(':')

redis_settings = { url: Redis.current.client.id,
                   namespace: sidekiq_namespace }

Sidekiq.configure_client do |config|
  config.redis = redis_settings
end

if Sidekiq::Client.method_defined? :reliable_push!
  Sidekiq::Client.reliable_push! unless Rails.env.test?
end

Sidekiq.configure_server do |config|
  config.super_fetch!
  config.reliable_scheduler!
  config.redis = redis_settings
  config.failures_default_mode = :exhausted
end

Sidekiq.default_worker_options = {
  backtrace: true,
  unique_expiration: 2.days,
  unique: :until_executed
}
