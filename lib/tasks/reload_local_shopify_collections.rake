namespace :shop do
  desc 'Reload local Shopify collections for all shops'
  task reload_local_shopify_collections: :environment do
    success_info = []
    error_info = []

    Shop.find_each do |shop|
      begin
        shop.reload_local_shopify_collections!
        puts "Shop: #{shop.id} - Local Shopify collections reloaded"
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
  end
end
