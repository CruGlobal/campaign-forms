# frozen_string_literal: true

source "https://rubygems.org"
source "https://gems.contribsys.com/" do
  gem "sidekiq-pro"
end

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.6.5"

gem "active_admin_flat_skin"
gem "activeadmin", "~> 1.3.0"
gem "activeadmin_addons"
gem "adobe-campaign", "~> 0.2"
gem "awesome_print"
gem "bootsnap", ">= 1.1.0", require: false
gem "brakeman"
gem "bundle-audit"
gem "ddtrace", "~> 0.24"
gem "devise"
gem "dogstatsd-ruby"
gem "font-awesome-rails"
gem "global_registry", "~> 1.5"
gem "jbuilder", "~> 2.5"
gem "lograge"
gem "loofah", ">= 2.2.3"
gem "newrelic_rpm"
gem "nokogiri", ">= 1.8.5"
gem "omniauth-cas", github: "CruGlobal/omniauth-cas"
gem "omniauth-rails_csrf_protection"
gem "ougai", "~> 1.7"
gem "pg", "~>0.18"
gem "puma", "~> 4.1"
gem "rack", ">= 2.0.6"
gem "rails", "~> 5.2.3"
gem "redis-namespace", "~> 1.5.3"
gem "redis-rails", "~> 5.0.2"
gem "rollbar"
gem "sass-rails", "~> 5.0"
gem "sidekiq-failures"
gem "sidekiq-unique-jobs", "~> 5.0.0"
gem "standardrb"
gem "strip_attributes", "~> 1.8.0"
gem "syslog-logger"
gem "uglifier", ">= 1.3.0"

group :development, :test do
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "capybara"
  gem "coveralls", require: false
  gem "database_cleaner"
  gem "dotenv-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "rspec-rails"
  gem "simplecov"
  gem "webmock"
end

group :development do
  gem "listen", ">= 3.0.5", "< 3.2"
  gem "pry"
  gem "pry-byebug"
  gem "rack-cors"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
end
