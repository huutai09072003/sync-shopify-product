SIDEKIQ_REDIS_CONFIGURATION = {
  url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1"),
  ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
}.freeze

Sidekiq.configure_server do |config|
  config.redis = SIDEKIQ_REDIS_CONFIGURATION
end

Sidekiq.configure_client do |config|
  config.redis = SIDEKIQ_REDIS_CONFIGURATION
end

Sidekiq.default_job_options = { retry: 8 }
