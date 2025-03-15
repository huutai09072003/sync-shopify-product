class LocalShopifyProductSerializer < ApplicationSerializer
  include ApplicationHelper

  attributes :id,
             :title,
             :variants,
             :featured_image,
             :status,
             :preview_count,
             :product,
             :activated_product_variants_count,
             :images,
             :preview_product_url

  attribute :id do
    object.original_id
  end

  attribute :variants do
    build_shopify_product_variants_json(object)
  end

  attribute :featured_image do
    object.original_data_image.try(:[], "src").to_s
  end

  attribute :product do
    object.product ? build_product_json(object.product) : nil
  end

  attribute :activated_product_variants_count do
    object.product&.enabled_product_variants_count || 0
  end

  attribute :images do
    build_shopify_product_images_json(object)
  end

  attribute :preview_product_url do
    preview_product_url(object, Current.shop)
  end

  private

  def build_product_json(product)
    product.attributes.slice('id', 'width', 'height', 'dimensions_unit', 'enabled')
  end

  def build_shopify_product_variants_json(object)
    object.original_data_variants.map do |variant|
      variant.slice('id', 'title')
    end
  end

  def build_shopify_product_images_json(object)
    object.original_data_images.map do |image|
      image.slice('id', 'src')
    end
  end
end
