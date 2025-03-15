namespace :shop do
  desc 'Add Shopify create collection webhook and Shopify update collection webhook and Shopify delete collection webhook to shops'
  task add_shopify_create_collection_webhook_and_shopify_update_collection_webhook_and_shopify_delete_collection_webhook_to_shops: :environment do
    success_info = []
    error_info = []

    Shop.find_each do |shop|
      begin
        webhooks = PictureItShopifyApi::WebhookSubscription.all(
          session: shop.shopify_session,
        ).data

        if webhooks.map(&:topic).exclude?("COLLECTIONS_CREATE")
          base_url = Rails.application.credentials.base_url
          webhook = PictureItShopifyApi::WebhookSubscription.new(session: shop.shopify_session)
          webhook.topic = "COLLECTIONS_CREATE"
          webhook.callback_url = "#{base_url}/webhooks/collections_create"
          webhook.format = "JSON"
          webhook.save!
          puts "Webhook collections/create for shop: #{shop.id}"
        end

        if webhooks.map(&:topic).exclude?("COLLECTIONS_UPDATE")
          base_url = Rails.application.credentials.base_url
          webhook = PictureItShopifyApi::WebhookSubscription.new(session: shop.shopify_session)
          webhook.topic = "COLLECTIONS_UPDATE"
          webhook.callback_url = "#{base_url}/webhooks/collections_update"
          webhook.format = "JSON"
          webhook.save!
          puts "Webhook collections/update for shop: #{shop.id}"
        end

        if webhooks.map(&:topic).exclude?("COLLECTIONS_DELETE")
          base_url = Rails.application.credentials.base_url
          webhook = PictureItShopifyApi::WebhookSubscription.new(session: shop.shopify_session)
          webhook.topic = "COLLECTIONS_DELETE"
          webhook.callback_url = "#{base_url}/webhooks/collections_delete"
          webhook.format = "JSON"
          webhook.save!
          puts "Webhook collections/delete for shop: #{shop.id}"
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
