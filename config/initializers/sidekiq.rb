# frozen_string_literal: true

require "redis"

redis_conf = YAML.safe_load(ERB.new(File.read(Rails.root.join("config", "redis.yml"))).result, [Symbol], [], true)["sidekiq"]

Redis.current = Redis.new(redis_conf)

redis_settings = {url: Redis.current.id}

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
  unique: :until_executed,
}
