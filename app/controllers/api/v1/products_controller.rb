class Api::V1::ProductsController < Api::V1::BaseController
  include ProductFilters

  before_action :check_if_already_created, only: [:create]
  before_action :set_product, only: [:show, :update, :destroy]
  before_action :set_product_filter, only: [:index]

  def index
    all_products = @shop.products.send(@product_filter)

    # Filter products by variant depends on Settings - enable variants toggle || params[:only_parents]
    if !@shop.enable_variants || params[:only_parents].to_b
      all_products = all_products.only_parents
    end
    all_products = all_products.order('title, created_at') if @product_filter == 'all'

    pagy, products = if params[:page]
      pagy(all_products)
    else
      [nil, all_products]
    end

    render json: products, each_serializer: ProductSerializer, meta: pagination_meta(pagy), adapter: :json
  end

  def show
    serializer = if params[:includes_variants].to_b
      ProductWithVariantsSerializer
    else
      ProductSerializer
    end

    render json: @product, serializer:, adapter: :json
  end

  def create
    shopify_product = PictureItShopifyApi::Product.find(params[:id])

    active_product_result = @shop.active_product(shopify_product, activate_variants: is_activate_variants?)
    success = active_product_result[:success]
    product = active_product_result[:product]

    if success
      render json: product, serializer: ProductSerializer, adapter: :json, status: :created
    else
      render json: product.errors, status: :unprocessable_entity
    end
  end

  # move to bg job
  def bulk_activate
    shopify_product_ids = params[:ids]

    unless is_override?
      shopify_product_ids = shopify_product_ids - @shop.products.only_parents.pluck(:external_id)
    end

    BulkActivateProductsJob.perform_later(@shop.id, shopify_product_ids, is_activate_variants: is_activate_variants?)

    render json: { message: 'Products activating' }, status: :created
  end

  def bulk_deactivate
    ids = params[:ids]
    products = @shop.products.only_parents.by_id(ids)

    products.update_all(enabled: false)

    LocalShopifyProduct.with_original_id(products.pluck(:external_id)).update_all(status: LocalShopifyProduct.statuses[:deactivated])

    if params[:is_deactivate_variants].to_b
      variants_products = @shop.products.by_parent_id(ids)
      variants_products.update_all(enabled: false)
      variants_products.find_each do |product|
        CacheManager::Product.new(product).purge_cache
      end
    end

    products.find_each do |product|
      product.recalculate_enabled_product_variants_count
      CacheManager::Product.new(product).purge_cache
    end

    render json: { message: 'Products deactivated' }, status: :ok
  end

  def toggle_bulk_use_parent_image
    ids = params[:ids]
    is_use_parent_image = params[:is_use_parent_image].to_b
    products = @shop.products.only_parents.by_id(ids)

    products.update_all(is_use_parent_image: is_use_parent_image)

    variants_products = @shop.products.by_parent_id(ids)
    variants_products.update_all(is_use_parent_image: is_use_parent_image)
    variants_products.find_each do |product|
      CacheManager::Product.new(product).purge_cache
    end

    products.find_each do |product|
      CacheManager::Product.new(product).purge_cache
    end

    render json: { message: 'Products use parent image' }, status: :ok
  end

  def update
    if @product.update(product_params)
      CacheManager::Product.new(@product).purge_cache

      if @product.is_variant && @product.enabled && @product.parent
        @product.parent.update(enabled: true)
        CacheManager::Product.new(@product.parent).purge_cache
      end

      if !@product.is_variant && !@product.enabled
        @product.product_variants.update_all(enabled: false)
        @product.product_variants.find_each do |product|
          CacheManager::Product.new(product).purge_cache
        end
        @product.recalculate_enabled_product_variants_count
      end

      (params["variants_attributes"] || []).each do |variant_attributes|
        variant =  @product.product_variants.find(variant_attributes[:id])
        variant_params = variant_attributes.permit(:width, :dimensions_unit, :height, :enabled, :image_url)
        variant.update(variant_params.merge(
          @product.is_variant ? {} : { is_use_parent_image: @product.is_use_parent_image }
        ))
        CacheManager::Product.new(variant).purge_cache
      end

      if @product.image_url && @product.image_url.exclude?('pictureit.co') && ENV.fetch("IS_USING_CDN") { true }.to_b
        # @product.copy_image_to_cdn_without_delay(true) # October 2022 - ensure customer can see latest changes and not wait for unrelated BG jobs
        @product.copy_image_to_cdn(true)
      end

      @product.update_status_of_local_shopify_product

      render json: @product, serializer: ProductSerializer, adapter: :json
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy if @product
    CacheManager::Product.new(@product).purge_cache
    head :no_content
  end

  private

  def product_params
    params.permit(:enabled, :width, :dimensions_unit, :height, :is_use_parent_image, :image_url, :featured_image, :background_collection_id)
  end

  def set_product
    @product = @shop.products.find(params[:id])
  end

  def is_override?
    params[:is_override].to_b
  end

  def is_activate_variants?
    params[:is_activate_variants].to_b
  end

  def check_if_already_created
    if already_created_product = @shop.products.find_by(external_id: params[:id]) && !is_override?
      render json: already_created_product, serializer: ProductSerializer, adapter: :json, status: :ok
    end
  end
end
