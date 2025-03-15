class Api::V1::LocalShopifyCollectionsController < Api::V1::BaseController
  def index
    local_shopify_collections = @shop.local_shopify_collections.limit(2000)

    render json: local_shopify_collections, each_serializer: LocalShopifyCollectionSerializer, adapter: :json
  end
end
