# frozen_string_literal: true

require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
# require 'active_job/railtie'
require "active_record/railtie"
require "action_controller/railtie"
# require "action_mailer/railtie"
# require 'action_view/railtie'
# require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"

require_relative "../lib/log/logger"
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CampaignForms
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    redis_conf = YAML.safe_load(ERB.new(File.read(Rails.root.join("config", "redis.yml"))).result, [Symbol], [], true)["cache"]
    redis_conf[:url] = "redis://" + redis_conf[:host] + "/" + redis_conf[:db].to_s
    config.cache_store = :redis_cache_store, redis_conf

    # Enable ougai
    if Rails.env.development? || Rails.const_defined?("Console")
      config.logger = Log::Logger.new($stdout)
    elsif !Rails.env.test? # use default logger in test env
      config.logger = Log::Logger.new(Rails.root.join("log", "datadog.log"))
    end
  end
end
