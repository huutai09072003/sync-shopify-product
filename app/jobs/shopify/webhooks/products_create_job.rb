class Shopify::Webhooks::ProductsCreateJob < ActiveJob::Base
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

    begin # fetch shopify product
      shopify_product = PictureItShopifyApi::Product.find(params[:webhook][:id], session: shop.shopify_session, fields: LocalShopifyProductable::LOCAL_SHOPIFY_PRODUCTABLE_QUERY_FIELDS)
      shop.save_shopify_product_to_db(shopify_product)
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.info("Shopify::Webhooks::ProductsCreateJob: Product with ID #{params[:webhook][:id]} not found, skipping job, message: #{e.message}")
    end
  end
end
