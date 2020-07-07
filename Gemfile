source "https://rubygems.org"
source "https://gems.contribsys.com/" do
  gem "sidekiq-pro"
end

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.6.6"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 6.0.3"
# Use sqlite3 as the database for Active Record
# gem 'sqlite3', '~> 1.4'
# Use Puma as the app server
gem "puma", "~> 4.1"
# Use SCSS for stylesheets
gem "sass-rails", ">= 6"
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem "webpacker", "~> 4.0"
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
# gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.7"
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.2", require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", ">= 3.3.0"
  gem "listen", "~> 3.2"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", ">= 2.15"
  gem "selenium-webdriver"
  # Easy installation and use of web drivers to run system tests with browsers
  gem "webdrivers"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem "pg", "~>0.18"

gem "active_admin_flat_skin"
gem "activeadmin", "~> 2.7.0"
gem "activeadmin_addons"
gem "adobe-campaign", "~> 0.2"
gem "awesome_print"
gem "brakeman"
gem "bundle-audit"
gem "countries"
gem "ddtrace", "~> 0.24"
gem "devise"
gem "dogstatsd-ruby"
gem "font-awesome-rails"
gem "global_registry", "~> 1.5"
gem "lograge"
gem "loofah", ">= 2.2.3"
gem "nokogiri", ">= 1.8.5"
gem "omniauth-cas", github: "CruGlobal/omniauth-cas"
gem "omniauth-rails_csrf_protection"
gem "ougai", "~> 1.7"
gem "redis-actionpack"
gem "redis-namespace"
gem "rollbar"
gem "sidekiq-failures"
gem "sidekiq-unique-jobs", "~> 5.0.0"
gem "standardrb"
gem "strip_attributes", "~> 1.11.0"

group :development, :test do
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
  gem "pry"
  gem "pry-byebug"
  gem "rack-cors"
end
