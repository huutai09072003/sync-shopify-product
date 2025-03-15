class CacheManager::Product
  attr_accessor :product

  def initialize(product)
    @product = product
  end

  def purge_cache
    purge_cached_widget_product_data
    purge_cached_product_by_external_product
  end

  def cached_widget_product_data
    Rails.cache.fetch("widget_product_data/#{product.id}", expires_in: 3.seconds) do
      {
        enabled: product.enabled,
        external_id: product.external_id,
        ar_product_id: product.id,
        gltf_url: product.gltf_url,
        usdz_url: product.usdz_url,
        featured_image_url: product.image_url,
        width: product.width,
        dimensions_unit: product.dimensions_unit,
        height: product.height,
        title: product.title,
        width_in_mm: product.width_in_mm,
        height_in_mm: product.height_in_mm,
        product_id: product.product_id,
        handle: product.handle
      }
    end
  end

  def purge_cached_widget_product_data
    Rails.cache.delete("widget_product_data/#{product.id}")
  end

  def self.cached_product_by_external_product(product_id)
    Rails.cache.fetch("product_by_external_product/#{product_id}", expires_in: 1.day) do
      Product.find_by(external_id: product_id)
    end
  end

  def purge_cached_product_by_external_product
    Rails.cache.delete("product_by_external_product/#{product.external_id}")
  end
end
