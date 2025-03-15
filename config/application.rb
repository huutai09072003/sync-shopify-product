require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# patch to fix: visit_Psych_Nodes_Alias': Cannot load database configuration: Unknown alias: default (Psych::BadAlias)
module YAML
  class << self
    alias_method :load, :unsafe_load if YAML.respond_to? :unsafe_load
  end
end

module PictureIt
  class Application < Rails::Application
    config.assets.configure do |env|
      env.export_concurrent = false
    end

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')

    config.i18n.default_locale = :en

    # allow customers to iframe their FAQ behind a paywalled website
    # config.action_dispatch.default_headers = {
    #   'X-Frame-Options' => 'ALLOWALL',
    #   'frame-ancestors' => '*' # probably not needed! 'frame-ancestors' should live inside content-security-policy key/value
    # }

    # if this works, consider deleting default_headers above
    config.action_dispatch.default_headers.clear

    # for embedded Shopify app
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
      end
    end

    # customize generators
    config.generators do |g|
      g.test_framework  :rspec, :fixture => false
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
      g.view_specs = false
      g.helper_specs = false
      g.assets = false # stylesheets
      g.helper = true
    end

    # Use a real queuing backend for Active Job
    config.active_job.queue_adapter = :sidekiq

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
