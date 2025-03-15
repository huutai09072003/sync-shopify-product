class Shopify::Webhooks::ProductsDeleteJob < ActiveJob::Base
  extend ShopifyAPI::Webhooks::Handler

  class << self
    # new handle function
    def handle(topic:, shop:, body:)
      # delegate to pre-existing perform_later function
      perform_later(topic: topic, shop_domain: shop, webhook: body)
    end
  end

  def perform(params)
    shop = Shop.find_by(shopify_domain: params[:shop_domain])
    return unless shop

    shopify_product_id = params[:webhook][:id]
    local_shopify_product = shop.local_shopify_products.find_by(original_id: shopify_product_id)
    product = local_shopify_product&.product || shop.products.find_by(external_id: shopify_product_id)

    local_shopify_product&.destroy || product&.destroy
    if product
      CacheManager::Product.new(product).purge_cache
    end
  end
end
