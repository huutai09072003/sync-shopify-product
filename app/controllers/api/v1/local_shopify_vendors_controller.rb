class Api::V1::LocalShopifyVendorsController < Api::V1::BaseController
  def vendor_names
    vendor_names = get_vendor_names(@shop.local_shopify_products)
    render json: transform_response({ vendor_names: vendor_names }), adapter: :json
  end

  private

  def get_vendor_names(local_shopify_products)
    local_shopify_products.with_vendor_not_nil.select(:vendor).distinct.limit(1000).pluck(:vendor)
  end
end
