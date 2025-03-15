class Shopify::Webhooks::CollectionsCreateJob < ActiveJob::Base
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

    webhook = params[:webhook]
    begin
      shop.reload_local_shopify_collection_with_shopify_collection_id!(webhook[:id])
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.info("Shopify::Webhooks::CollectionsCreateJob: Collections with ID #{webhook[:id]} not found, skipping job, message: #{e.message}")
    end
  end
end
