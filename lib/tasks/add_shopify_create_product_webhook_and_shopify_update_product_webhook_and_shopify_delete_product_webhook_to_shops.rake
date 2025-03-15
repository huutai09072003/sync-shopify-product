namespace :shop do
  desc 'Add Shopify create product webhook and Shopify update product webhook and Shopify delete product webhook to shops'
  task add_shopify_create_product_webhook_and_shopify_update_product_webhook_and_shopify_delete_product_webhook_to_shops: :environment do
    success_info = []
    error_info = []

    Shop.find_each do |shop|
      begin
        webhooks = PictureItShopifyApi::WebhookSubscription.all(
          session: shop.shopify_session,
        ).data

        fields_for_products = %w[id title status handle vendor]

        if webhooks.map(&:topic).exclude?("PRODUCTS_CREATE")
          base_url = Rails.application.credentials.base_url
          webhook = PictureItShopifyApi::WebhookSubscription.new(session: shop.shopify_session)
          webhook.topic = "PRODUCTS_CREATE"
          webhook.callback_url = "#{base_url}/webhooks/products_create"
          webhook.format = "JSON"
          webhook.include_fields = fields_for_products
          webhook.save!
          puts "Webhook products/create for shop: #{shop.id}"
        end

        if webhooks.map(&:topic).exclude?("PRODUCTS_UPDATE")
          base_url = Rails.application.credentials.base_url
          webhook = PictureItShopifyApi::WebhookSubscription.new(session: shop.shopify_session)
          webhook.topic = "PRODUCTS_UPDATE"
          webhook.callback_url =  "#{base_url}/webhooks/products_update"
          webhook.format = "JSON"
          webhook.include_fields = fields_for_products
          webhook.save!
          puts "Webhook products/update for shop: #{shop.id}"
        end

        if webhooks.map(&:topic).exclude?("PRODUCTS_DELETE")
          base_url = Rails.application.credentials.base_url
          webhook = PictureItShopifyApi::WebhookSubscription.new(session: shop.shopify_session)
          webhook.topic = "PRODUCTS_DELETE"
          webhook.callback_url =  "#{base_url}/webhooks/products_delete"
          webhook.format = "JSON"
          webhook.include_fields = fields_for_products
          webhook.save!
          puts "Webhook products/delete for shop: #{shop.id}"
        end

        success_info << {
          shop_id: shop.id,
          shopify_domain: shop.shopify_domain,
        }
      rescue StandardError => e
        puts "Shop: #{shop.id} - Error: #{e.message}"
        error_info << {
          shop_id: shop.id,
          shopify_domain: shop.shopify_domain,
          error: e.message,
        }
      end
    end
    puts "Success info: #{success_info}"
    puts "Error info: #{error_info}"
  end
end
