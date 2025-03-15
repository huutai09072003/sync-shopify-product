source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.2'

gem 'activeadmin'
gem 'airbrake'
gem 'aws-sdk-s3', require: false
gem 'bootsnap', '>= 1.4.2', require: false
gem 'chartkick'
gem 'delayed_job_active_record'
gem 'devise'
gem 'groupdate' # chartkick data aggregation helpers
gem 'httparty'
gem 'jbuilder', '~> 2.7'
gem 'jsonb_accessor'
gem 'mini_magick'
gem 'pg'
gem 'puma', '~> 4.3.8'
gem 'rack-cors'
gem 'rails', '~> 6.0.0'
gem 'redis', '~> 4.0'
gem 'remove_bg', '1.3.0'
gem 'sass-rails', '~> 6'
gem 'shopify_app', '~> 22.5', '>= 22.5.1'
gem 'turbolinks', '~> 5'
gem 'psych', '< 4'
gem 'webpacker', '~> 4.0'
gem 'newrelic_rpm'
gem 'postmark-rails'
gem 'browser_sniffer'
gem 'pagy'

# net-* libraries added for Ruby 3.1.x upgrade that removed them
gem 'net-smtp', require: false
gem 'net-imap', require: false
gem 'net-pop', require: false

gem 'activerecord-has_token', '~> 0.0.3'

gem "image_processing", '~> 1.0'

gem 'active_storage_validations' # no validations in native library, using to prevent videos/etc file uploads

gem 'activeadmin_addons' # adds features like datepicker to active_admin

group :development, :test do
  gem 'pry'
  gem 'spring'
  gem 'letter_opener' # view mailers in browser
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.8'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'capistrano'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'
  gem 'capistrano-passenger'
  gem 'capistrano-nvm', require: false

  gem "ruby-lsp", require: false

  gem 'annotate'

  gem 'rails-erd'
end

group :test do
  gem 'rspec-rails', '~> 3.6.0'
  gem 'spring-commands-rspec'
  gem 'factory_bot_rails', '~> 5.2.0'
  gem 'rails-controller-testing'
  gem 'webdrivers', '5.2.0'
  gem 'selenium-webdriver'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'rack_session_access'
  gem 'webmock'
  gem 'shoulda-callback-matchers', '~> 1.1.1'
  gem 'shoulda-matchers', '~> 5.3.0'
  gem 'faker', :git => 'https://github.com/stympy/faker.git', :branch => 'main'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'active_model_serializers', '~> 0.10.13'
gem 'dotenv-rails' # don't use Rails credentials - CI doesn't have decryption key
gem 'wannabe_bool', '~> 0.7.1'
gem 'whenever'
gem 'nokogiri'
gem 'ransack'
gem 'sidekiq'
gem 'sidekiq-scheduler'

gem "loops_sdk", "~> 0.1.2"
