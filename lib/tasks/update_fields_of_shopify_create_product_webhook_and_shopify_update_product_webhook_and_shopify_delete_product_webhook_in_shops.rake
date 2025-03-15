namespace :shop do
  desc 'Update fields of Shopify create product webhook and Shopify update product webhook and Shopify delete product webhook in shops'
  task update_fields_of_shopify_create_product_webhook_and_shopify_update_product_webhook_and_shopify_delete_product_webhook_in_shops: :environment do
    success_info = []
    error_info = []

    Shop.find_each do |shop|
      begin
        webhooks = PictureItShopifyApi::WebhookSubscription.all(
          session: shop.shopify_session,
        ).data

        webhooks.each do |webhook|
          if webhook.topic == "PRODUCTS_CREATE" || webhook.topic == "PRODUCTS_UPDATE" || webhook.topic == "PRODUCTS_DELETE"
            webhook_fields = ['id', 'title', 'status', 'handle', 'vendor']
            webhook.include_fields = webhook_fields
            webhook.save!

            puts "Webhook #{webhook.topic} for shop: #{shop.id}"
          end
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
