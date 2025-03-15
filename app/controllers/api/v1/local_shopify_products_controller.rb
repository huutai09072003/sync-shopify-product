class Api::V1::LocalShopifyProductsController < Api::V1::BaseController
  def index
    q = @shop.local_shopify_products.ransack(params[:q])
    all_local_shopify_products = q.result.includes(:product).left_outer_joins(:local_shopify_collections).distinct

    pagy, local_shopify_products = if params[:page]
      pagy(all_local_shopify_products, items: params[:per_page] || 10)
    else
      [nil, all_local_shopify_products]
    end

    render json: local_shopify_products, each_serializer: LocalShopifyProductSerializer, meta: pagination_meta(pagy), adapter: :json
  end

  def show
    local_shopify_product = @shop.local_shopify_products.find_by!(original_id: (params[:id]))
    render json: local_shopify_product, serializer: LocalShopifyProductSerializer, adapter: :json
  ensure ActiveRecord::RecordNotFound
    render json: { error: 'Not Found' }, status: :not_found
  end

  def most_viewed
    last_days = params[:last_days].present? ? params[:last_days].to_i.days.ago.beginning_of_day : nil
    sort = params[:sort] || 'desc'
    limit = params[:per_page] || 5

    most_viewed_products = @shop.products.only_parents.joins(:events)
                            .merge(Event.previews)

    if last_days
      most_viewed_products = most_viewed_products.where('events.created_at >= ?', last_days)
    end

    most_viewed_products = most_viewed_products.group('events.object_id')
                            .order("COUNT(events.object_id) #{sort}")
                            .limit(limit)
                            .count('events.object_id')

    local_shopify_products = @shop.local_shopify_products
                              .includes(:product)
                              .where(products: { id: most_viewed_products.keys })

    pagy, local_shopify_products = pagy(local_shopify_products, items: limit)

    local_shopify_products.to_a.each do |local_shopify_product|
      local_shopify_product.custom_preview_count = most_viewed_products[local_shopify_product.product.id]
    end

    if local_shopify_products.present?
      local_shopify_products = LocalShopifyProduct.sort_products_by_preview_count_descending(local_shopify_products)
    end

    render json: local_shopify_products, each_serializer: LocalShopifyProductSerializer, meta: pagination_meta(pagy), adapter: :json
  end
end
