desc "Add live preview stats to a cache counter for UI filtering"
task cache_live_preview_stats: [:environment] do
  object_ids = Event.products.previews.where(created_at: 24.hours.ago..Time.now).pluck(:object_id).uniq

  object_ids.each do |object_id|
    product = Product.find_by_id(object_id)
    next unless product # may be deleted / shop canceled plan

    product.update(preview_count_cache: product.preview_count)
    if product.local_shopify_product
      product.local_shopify_product.update(preview_count: product.preview_count)
    end
  end
end

desc "Cleanup events that doesn't have object"
task cleanup_events: [:environment] do
  product_ids = Product.pluck(:id)
  Event.products.without_object_id(product_ids).delete_all
end

desc "Cleanup products that already deleted on Shopify"
task cleanup_deleted_products: [:environment] do
  Shop.find_each do |shop|
    shop.products.only_parents.each do |parent_product|
      will_delete_parent_product = false
      shopify_product = nil

      begin # fetch shopify product
        shopify_product = ShopifyAPI::Product.find(id: parent_product.external_id.to_i, session: shop.shopify_session)
      rescue ShopifyAPI::Errors::HttpResponseError => e
        if e.code == 404
          will_delete_parent_product = true
        end
      end

      if will_delete_parent_product
        parent_product.destroy
      elsif shopify_product
        shopify_product_variant_ids = shopify_product.variants.map(&:id)
        parent_product.product_variants.not_by_external_id(shopify_product_variant_ids).destroy_all
      end
    end
  end
end

desc "Cleanup local_shopify_products and products that doesn't have shop"
task cleanup_local_shopify_products_and_products_that_does_not_have_shop: [:environment] do
  shop_ids = Shop.pluck(:id)
  LocalShopifyProduct.without_shop_id(shop_ids).find_each do |local_shopify_product|
    local_shopify_product.destroy
  end
  Product.without_shop_id(shop_ids).find_each do |product|
    product.destroy
  end
end

desc "Update shop's chart data cache"
task update_chart_data_cache: [:environment] do
  Shop.find_each do |shop|
    shop.update(chart_data_cache: shop.chart_data)
  end
end
