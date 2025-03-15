class ProductManager::BulkActivate
  attr_reader :shop, :shopify_product_ids

  def initialize(shop, shopify_product_ids)
    @shop = shop
    @shopify_product_ids = shopify_product_ids
  end

  def run(is_activate_variants:)
    shop.update_columns(
      bulk_activating_products_at: Time.current,
      local_shopify_product_original_ids_that_is_activating_product: shopify_product_ids
    )
    shop.send_bulk_activate_products_status

    shopify_products = PictureItShopifyApi::Product.all(filter: {id: shopify_product_ids}, session: shop.shopify_session).data

    shopify_products.each do |shopify_product|
      @shop.active_product(shopify_product, activate_variants: is_activate_variants)
    end
  ensure
    shop.update_columns(
      bulk_activating_products_at: nil,
      local_shopify_product_original_ids_that_is_activating_product: []
    )
    shop.send_bulk_activate_products_status(product_ids_just_activated: Product.by_external_id(shopify_product_ids).pluck(:id))
  end
end
