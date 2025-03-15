class Shopify::Webhooks::ProductsUpdateJob < ActiveJob::Base
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

    if webhook.has_key?("status") && webhook["status"].to_s.downcase != "active"
      LocalShopifyProduct.find_by(original_id: webhook[:id])&.destroy
      return
    end

    begin # fetch shopify product
      shopify_product = PictureItShopifyApi::Product.find(webhook[:id], session: shop.shopify_session, fields: LocalShopifyProductable::LOCAL_SHOPIFY_PRODUCTABLE_QUERY_FIELDS)
      local_shopify_product = shop.save_shopify_product_to_db(shopify_product)

      local_shopify_product.product&.product_variants&.not_by_external_id(
        local_shopify_product.variant_ids
      )&.destroy_all
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.info("Shopify::Webhooks::ProductsCreateJob: Product with ID #{webhook[:id]} not found, skipping job, message: #{e.message}")
    end
  end
end
