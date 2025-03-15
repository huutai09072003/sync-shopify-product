namespace :shop do
  desc 'Reload Shopify products for all shops'
  task reload_local_shopify_products: :environment do
    success_info = []
    error_info = []

    Shop.find_each do |shop|
      begin
        shop.reload_local_shopify_products!
        puts "Shop: #{shop.id} - Local Shopify products reloaded"
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

  # Use only when necessary
  task reload_local_shopify_products_save_to_db_directly: :environment do
    success_info = []
    error_info = []

    Shop.find_each do |shop|
      begin
        begin
          shop.reload_local_shopify_products!(save_to_db_directly: true)
        rescue StandardError => e
          shop.reload_local_shopify_products!(save_to_db_directly: true, batch_size: 50)
        end
        puts "Shop: #{shop.id} - Local Shopify products reloaded"
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

  task remove_draft_local_shopify_products: :environment do
    success_info = []
    error_info = []
    batch_size = 250

    shop_products_count = Shop.all.map do |s|
      {
        id: s.id,
        shopify_product_count: (s.shopify_product_count rescue 0),
        local_shopify_product_count: s.local_shopify_products.size
      }
    end
    shop_products_count = shop_products_count.select { |s| s[:shopify_product_count] != s[:local_shopify_product_count] }
    shop_ids = shop_products_count.map{ |s| s[:id] }

    Shop.where(id: shop_ids).find_each do |shop|
      begin
        shopify_product_ids = []
        shopify_products = ShopifyAPI::Product.all(limit: batch_size, session: shop.shopify_session, status: 'active', fields: 'id')

        shopify_product_ids.push(*shopify_products.map(&:id))

        while ShopifyAPI::Product.next_page?
          shopify_products = ShopifyAPI::Product.all(limit: batch_size, page_info: ShopifyAPI::Product.next_page_info, session: shop.shopify_session, fields: 'id')
          shopify_product_ids.push(*shopify_products.map(&:id))
        end

        shop.local_shopify_products.where.not(original_id: shopify_product_ids).find_each do |local_shopify_product|
          local_shopify_product.destroy
        end

        puts "Shop: #{shop.id} - Draft Local Shopify products removed"
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
