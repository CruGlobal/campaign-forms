# Rails 8 compatibility settings
# Ensure smooth transition to Rails 8

if Rails::VERSION::MAJOR >= 8
  # Disable deprecation warnings in development for smoother upgrade
  ActiveSupport::Deprecation.silenced = true if Rails.env.development?
  
  # Configure autoloading
  Rails.autoloaders.main.ignore(Rails.root.join('app/assets')) if Dir.exist?(Rails.root.join('app/assets'))
  Rails.autoloaders.main.ignore(Rails.root.join('app/javascript')) if Dir.exist?(Rails.root.join('app/javascript'))
end
