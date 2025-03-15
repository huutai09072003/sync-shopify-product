class Api::V1::ShopifyProductsController < Api::V1::BaseController
  before_action :set_product, only: [:show]

  def index
    page = filter_params[:page].to_i || 1

    api_serach

    has_more = total_shopify_product_count > ((page - 1) * 50) + @shopify_products.count
    number_of_pages = (total_shopify_product_count / 48.to_f).ceil # always round up

    if @search_type == 'api' && !@api_results # using hack_search, no pagination available
      has_more = nil
    end

    meta = { current_page: page, has_more: has_more, total_count: total_shopify_product_count, total_pages: number_of_pages }

    if @api_results
      meta = meta.merge(has_more: ShopifyAPI::Product.next_page?, cursor_info: { next_page: ShopifyAPI::Product.next_page_info, prev_page: ShopifyAPI::Product.prev_page_info })
    end

    render json: transform_response({
      shopify_products: build_shopify_products_json(@shopify_products),
      meta: meta
    }), status: 200
  end

  def show
    shopify_product = PictureItShopifyApi::Product.find(@product.product_id, fields: LocalShopifyProductable::LOCAL_SHOPIFY_PRODUCTABLE_QUERY_FIELDS)
    local_shopify_product = @shop.local_shopify_products.new(
      @shop.build_local_shopify_product_attributes(shopify_product)
    )

    render json: transform_response(shopify_product: LocalShopifyProductSerializer.new(local_shopify_product).as_json)
  rescue StandardError => e
    render json: { error: e.message }, status: 404
  end

  private

  def set_product
    @product = @shop.products.find(params[:id])
  end

  def api_serach
    search_params = {}
    search_params.merge!({title: filter_params['q']}) unless filter_params['q'].blank?
    search_params.merge!({ page_info: filter_params[:cursor_page_info] }) unless filter_params[:cursor_page_info].blank?

    @api_results = ShopifyAPI::Product.all(**search_params)
    @search_type = 'api'
    @shopify_products = @api_results

    if @api_results.count.zero? && filter_params[:cursor_page_info].blank? && filter_params['q'].present?
      @shopify_products = hack_search
      @api_results = nil
    else
      @api_results
    end
  end

  def hack_search
    filtered_shopify_products = []
    loops = 0
    batch_size = 250
    all_shopify_products = ShopifyAPI::Product.all(limit: batch_size)
    filtered_shopify_products.push(*filter_shopify_products(all_shopify_products))
    while ShopifyAPI::Product.next_page? && filtered_shopify_products.count < 50 && loops < 10 # find 50 products or search 2500
      sleep(1)
      all_shopify_products = ShopifyAPI::Product.all(limit: batch_size, page_info: ShopifyAPI::Product.next_page_info)
      filtered_shopify_products.push(*filter_shopify_products(all_shopify_products))
      loops += 1
    end
    filtered_shopify_products
  end

  def filter_shopify_products(shopify_products)
    return shopify_products unless filter_params['q'].present?
    query = filter_params['q'].downcase
    shopify_products.select do |pro|
      pro.title.downcase.include?(query) ||
      pro.vendor.downcase.include?(query) ||
      pro.handle.downcase.include?(query) ||
      pro.tags.downcase.include?(query) ||
      (pro.body_html && pro.body_html.downcase.include?(query))
    end
  end

  def total_shopify_product_count
    @total_shopify_product_count ||= @shop.cached_shopify_product_count
  end

  def filter_params
    params.permit(:q, :page, :cursor_page_info)
  end

  def build_shopify_products_json(shopify_products)
    shopify_product_ids = shopify_products.map(&:id)
    parent_products = @shop.products.only_parents.by_external_id(shopify_product_ids).includes(:product_variants)

    shopify_products.map do |shopify_product|
      local_shopify_product = @shop.local_shopify_products.new
      # add associated parent_product to local_shopify_product before assigning attributes because it will re-query to the database if you add original_id first
      local_shopify_product.product = parent_products.find { |parent_product| parent_product.external_id == shopify_product.id.to_s }
      local_shopify_product.assign_attributes(@shop.build_local_shopify_product_attributes(shopify_product))
      LocalShopifyProductSerializer.new(local_shopify_product).as_json
    end
  end
end
