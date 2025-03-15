namespace :move_domain_to_app_pictureit_co do
  desc 'Update script tags of shops to app.pictureit.co'
  task update_script_tags_of_shops_to_app_pictureit_co: :environment do
    success_info = []
    error_info = []
    old_domain = "/pictureit.co/"
    new_domain = "/app.pictureit.co/"

    Shop.find_each do |shop|
      script_tags = ShopifyAPI::ScriptTag.all(session: shop.shopify_session) rescue []
      begin
        script_tags.each do |script_tag|
          if script_tag.src.include?(old_domain) && script_tag.src.include?("/load.js")
            script_tag.src = script_tag.src.gsub(old_domain, new_domain)
            script_tag.save!
            puts "Updated script tag id #{script_tag.id} for shop: #{shop.id}"
            success_info << {
              shop_id: shop.id,
              script_tag_id: script_tag.id,
              shopify_domain: shop.shopify_domain,
            }
          end
        end
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

  desc 'Update webhooks of shops to app.pictureit.co'
  task update_webhooks_of_shops_to_app_pictureit_co: :environment do
    success_info = []
    error_info = []
    old_domain = "/pictureit.co/"
    new_domain = "/app.pictureit.co/"

    Shop.find_each do |shop|
      webhooks = ShopifyAPI::Webhook.all(session: shop.shopify_session) rescue []
      begin
        webhooks.each do |webhook|
          if webhook.address.include?(old_domain)
            webhook.address = webhook.address.gsub(old_domain, new_domain)
            webhook.save!
            puts "Updated webhook id #{webhook.id} for shop: #{shop.id}"
            success_info << {
              shop_id: shop.id,
              webhook_id: webhook.id,
              shopify_domain: shop.shopify_domain,
            }
          end
        end
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

  desc 'Update background collections of shops to app.pictureit.co'
  task update_background_collections_of_shops_to_app_pictureit_co: :environment do
    success_info = []
    error_info = []
    old_domain = "/pictureit.co/"
    new_domain = "/app.pictureit.co/"

    Shop.find_each do |shop|
      background_collections = shop.background_collections
      begin
        background_collections.each do |background_collection|
          bg_images = background_collection.bg_images
          bg_images.each do |bg_image|
            src = bg_image["src"].to_s
            if src.include?(old_domain) && (src.include?("/bg-assets") || src.include?("/bg-assets-orig"))
              bg_image["src"] = src.gsub(old_domain, new_domain)
            end
          end
          background_collection.bg_images = bg_images
          background_collection.save!
          puts "Updated background collection id #{background_collection.id} for shop: #{shop.id}"
          success_info << {
            shop_id: shop.id,
            background_collection_id: background_collection.id,
            shopify_domain: shop.shopify_domain,
          }
        end
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

  desc 'Update image proxies to app.pictureit.co'
  task update_image_proxies_to_app_pictureit_co: :environment do
    old_domain = "/pictureit.co/"
    new_domain = "/app.pictureit.co/"

    ImageProxy.where('src like ?', "%#{old_domain}%").find_each do |image_proxy|
      image_proxy.src = image_proxy.src.gsub(old_domain, new_domain)
      image_proxy.save!
      puts "Updated image proxy id #{image_proxy.id}"
    end
  end
end
