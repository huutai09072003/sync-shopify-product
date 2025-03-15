ShopifyApp.configure do |config|
  base_url = Rails.application.credentials.base_url

  config.application_name = "Picture It for Shopify"
  config.old_secret = ""
  config.scope = "write_script_tags,read_script_tags,read_themes,read_products"
                # Consult this page for more scope options:
                # https://help.shopify.com/en/api/getting-started/authentication/oauth/scopes
  config.embedded_app = true
  config.after_authenticate_job = { job: Shopify::AfterAuthenticateJob, inline: !Rails.env.production? }
  config.api_version = "2025-01"
  config.shop_session_repository = 'Shop'
  config.log_level = :info
  config.reauth_on_access_scope_changes = true

  # webhooks
  # ------------------- #
  config.webhook_jobs_namespace = 'shopify/webhooks'
  product_fields = ['id', 'title', 'status', 'handle', 'vendor']
  config.webhooks = [
    { topic: "app/uninstalled", address: "#{base_url}/webhooks/app_uninstalled"},
    { topic: "products/delete", address: "#{base_url}/webhooks/products_delete", fields: product_fields},
    { topic: "products/update", address: "#{base_url}/webhooks/products_update", fields: product_fields},
    { topic: "products/create", address: "#{base_url}/webhooks/products_create", fields: product_fields},
    { topic: "collections/delete", address: "#{base_url}/webhooks/collections_delete"},
    { topic: "collections/update", address: "#{base_url}/webhooks/collections_update"},
    { topic: "collections/create", address: "#{base_url}/webhooks/collections_create"},
  ]

  config.api_key = Rails.application.credentials.shopify[:api_key]
  config.secret = Rails.application.credentials.shopify[:api_secret]

  # You may want to charge merchants for using your app. Setting the billing configuration will cause the Authenticated
  # controller concern to check that the session is for a merchant that has an active one-time payment or subscription.
  # If no payment is found, it starts off the process and sends the merchant to a confirmation URL so that they can
  # approve the purchase.
  #
  # Learn more about billing in our documentation: https://shopify.dev/apps/billing
  # config.billing = ShopifyApp::BillingConfiguration.new(
  #   charge_name: "My app billing charge",
  #   amount: 5,
  #   interval: ShopifyApp::BillingConfiguration::INTERVAL_EVERY_30_DAYS,
  #   currency_code: "USD", # Only supports USD for now
  #   trial_days: 0
  #   test: ENV.fetch('SHOPIFY_TEST_CHARGES', !Rails.env.production?)
  # )

  if defined? Rails::Server
    raise('Missing SHOPIFY_API_KEY. See https://github.com/Shopify/shopify_app#requirements') unless config.api_key
    raise('Missing SHOPIFY_API_SECRET. See https://github.com/Shopify/shopify_app#requirements') unless config.secret
  end
end

Rails.application.config.after_initialize do
  if ShopifyApp.configuration.api_key.present? && ShopifyApp.configuration.secret.present?
    ShopifyAPI::Context.setup(
      api_key: ShopifyApp.configuration.api_key,
      api_secret_key: ShopifyApp.configuration.secret,
      api_version: ShopifyApp.configuration.api_version,
      host: Rails.application.credentials.base_url,
      scope: ShopifyApp.configuration.scope,
      is_private: !ENV.fetch('SHOPIFY_APP_PRIVATE_SHOP', '').empty?,
      is_embedded: ShopifyApp.configuration.embedded_app,
      log_level: :info,
      logger: Rails.logger,
      private_shop: ENV.fetch('SHOPIFY_APP_PRIVATE_SHOP', nil),
      user_agent_prefix: "ShopifyApp/#{ShopifyApp::VERSION}"
    )

    ShopifyApp::WebhooksManager.add_registrations
  end

  class ShopifyAPI::Shop
    def self.current(session: ShopifyAPI::Context.active_session, fields: nil)
      ShopifyAPI::Shop.all(session: session, fields: fields).first
    end
  end

  class ShopifyAPI::RecurringApplicationCharge
    def self.current(session: ShopifyAPI::Context.active_session, fields: nil)
      ShopifyAPI::RecurringApplicationCharge.all(session: session, fields: fields).find{ |charge| charge.status == 'active' }
    end
  end
end
