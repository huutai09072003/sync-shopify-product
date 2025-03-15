class Shopify::Webhooks::CollectionsDeleteJob < ActiveJob::Base
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

    shopify_collection_id = params[:webhook][:id]
    shop.local_shopify_collections.find_by(original_id: shopify_collection_id)&.destroy
  end
end
