# frozen_string_literal: true

source 'https://rubygems.org'
source 'https://gems.contribsys.com/' do
  gem 'sidekiq-pro'
end

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'active_admin_flat_skin'
gem 'activeadmin', '~> 1.0.0'
gem 'adobe-campaign', '~> 0.2'
gem 'devise'
gem 'font-awesome-rails'
gem 'global_registry', '~> 1.5'
gem 'jbuilder', '~> 2.5'
gem 'newrelic_rpm'
gem 'omniauth-cas', github: 'CruGlobal/omniauth-cas'
gem 'pg', '~>0.18'
gem 'puma', '~> 3.7'
gem 'rails', '~> 5.1.4'
gem 'redis-namespace'
gem 'redis-rails', '~> 5.0.2'
gem 'rollbar'
gem 'sass-rails', '~> 5.0'
gem 'sidekiq-failures'
gem 'sidekiq-unique-jobs', '~> 5.0.0'
gem 'strip_attributes', '~> 1.8.0'
gem 'syslog-logger'
gem 'uglifier', '>= 1.3.0'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv-rails'
  gem 'rubocop-cru'
end

group :development do
  gem 'awesome_print'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'pry'
  gem 'pry-byebug'
  gem 'rack-cors'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
