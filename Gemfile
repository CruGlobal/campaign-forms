source "https://rubygems.org"
source "https://gems.contribsys.com/" do
  gem "sidekiq-pro"
end

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby file: ".ruby-version"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.7"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use sqlite3 as the database for Active Record
# gem "sqlite3", "~> 1.4"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Sass to process CSS
gem "sassc-rails"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri mingw x64_mingw]
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  # gem "webdrivers"
end

gem "pg"

gem "activeadmin"
gem "activeadmin_addons"
gem "adobe-campaign", "~> 0.2"
gem "awesome_print"
gem "brakeman"
gem "bundle-audit"
gem "concurrent-ruby", "1.3.4" # remove when upgrading to Rails 7.1
gem "countries"
gem "datadog"
gem "devise"
gem "dogstatsd-ruby", "~> 5.3"
gem "font-awesome-rails"
gem "global_registry", "~> 1.5"
gem "lograge"
gem "loofah", ">= 2.2.3"
gem "nokogiri", ">= 1.8.5"
gem "omniauth-oktaoauth", github: "CruGlobal/omniauth-oktaoauth"
gem "omniauth-rails_csrf_protection"
gem "ougai", "~> 1.7"
gem "rack-cors"
gem "redis", "< 5.0"
gem "redis-actionpack"
gem "rollbar"
gem "sidekiq", "~> 6.5.10"
gem "sidekiq-failures"
gem "sidekiq-unique-jobs"
gem "standardrb"
gem "strip_attributes", "~> 1.11"

group :development, :test do
  gem "database_cleaner-active_record"
  gem "dotenv-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "rspec-rails"
  gem "simplecov-cobertura", require: false
  gem "webmock"
end
