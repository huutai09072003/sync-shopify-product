class Shopify::Webhooks::AppUninstalledJob < ActiveJob::Base
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

    # store a backup for analysis / marketing
    deleted_shop = DeletedShop.new(
      first_name: shop.first_name,
      last_name: shop.last_name,
      vanity_domain: shop.vanity_domain,
      shopify_domain: shop.shopify_domain,
      shopify_token: shop.shopify_token,
      store_name: shop.store_name,
      admin_email: shop.admin_email,
      client_id: shop.client_id,
      preferences: shop.preferences
    )

    shop.destroy! if deleted_shop.save!
  end
end
