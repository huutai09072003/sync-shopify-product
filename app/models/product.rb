class Product < ApplicationRecord
  belongs_to :shop
  belongs_to :parent, class_name: 'Product', optional: true, counter_cache: :product_variants_count
  belongs_to :local_shopify_product, foreign_key: :external_id, primary_key: :original_id, optional: true, inverse_of: :product

  has_many :product_variants, class_name: 'Product', foreign_key: 'parent_id', dependent: :destroy
  has_many :enabled_product_variants, -> { enabled }, class_name: 'Product', foreign_key: 'parent_id'
  has_many :events, as: :objectable, foreign_key: :object_id, foreign_type: :object_class

  has_one_attached :gltf_file
  has_one_attached :usdz_file
  has_many_attached :images

  after_commit :copy_image_to_cdn_with_delay, on: :create
  before_save :purge_gltf_file_and_usdz_file, if: -> {
    self.persisted? &&
      (width_changed? || height_changed? || dimensions_unit_changed? || image_url_changed?)
  }
  after_save :recalculate_enabled_product_variants_count, if: -> { parent && saved_change_to_enabled? }
  after_destroy :recalculate_enabled_product_variants_count, if: -> { parent }

  validates_uniqueness_of :external_id, case_sensitive: false
  validates_presence_of :image_url, if: :enabled?
  validates :dimensions_unit, inclusion: { in: %w(centimetres inches) }, allow_nil: true

  jsonb_accessor :meta, {
    title: [:text],
    body_html: [:text],
    vendor: [:text],
    product_type: [:text],
    handle: [:text],
    template_suffix: [:text],
    tags: [:text],
    image: [:text],
    product_id: [:text],
    has_variants: [:boolean],
    variants_ids: [:jsonb],
  }

  scope :least_viewed, -> { order(preview_count_cache: :asc) }
  scope :most_viewed, -> { order(preview_count_cache: :desc) }
  scope :recently_added, -> { order(updated_at: :desc) }
  scope :by_external_id, ->(external_id) { where(external_id: external_id) }
  scope :not_by_external_id, ->(external_id) { where.not(external_id: external_id) }
  scope :only_parents, -> { where(parent_id: nil) }
  scope :by_id, ->(id) { where(id: id) }
  scope :by_parent_id, ->(parent_id) { where(parent_id: parent_id) }
  scope :enabled, -> { where(enabled: true) }
  scope :disabled, -> { where(enabled: false) }
  scope :with_shop_id, ->(shop_id) { where(shop_id: shop_id) }
  scope :without_shop_id, ->(shop_id) { where.not(shop_id: shop_id) }

  def is_variant
    parent_id.present?
  end
  alias :is_variant? :is_variant

  def gltf_url
    return nil unless gltf_file.attached?
    gltf_file.service_url
  end

  def usdz_url
    return nil unless usdz_file.attached?
    usdz_file.service_url
  end

  def width_in_mm
    return nil if width.blank? || width == 0.0
    (width * dimensions_unit_to_mm_formula_multiplier).to_i
  end

  def height_in_mm
    return nil if height.blank? || height == 0.0
    (height * dimensions_unit_to_mm_formula_multiplier).to_i
  end

  def dimensions_unit_to_mm_formula_multiplier
    return 0 unless dimensions_unit
    return 10 if dimensions_unit == 'centimetres'
    return 25.4 if dimensions_unit == 'inches'
  end

  def images_urls(order: nil)
    all_images = images
    all_images = all_images.order(order) if order
    all_images.map do |image|
      if image.byte_size > 5.megabytes # if image is greater than 5MB, resize it
        variant_image = generate_image_variant(image) rescue image
      end
      { attachment_id: image.id,
        src: friendly_url(variant_image || image),
        background_removed: image.filename.to_s.include?('(background removed)')
      }
    end
  end

  def background_collection
    # added 10.4.22 - handles edge case where store deletes/reinstalls ~1 day apart,
    # and Rails cache still stores their deleted products (LivePreviewController#find_cached_product), breaking live preview image lookup
    @shop = shop || Product.where(external_id: external_id).last.shop

    return @shop.default_background_collection unless background_collection_id
    collection = @shop.background_collections.find_by(id: background_collection_id)
    return @shop.default_background_collection unless collection && collection.bg_images.length > 0 # never return empty collection
    collection
  end

  # TODO: find a better way to do this. when user uploads custom background image, it can't be used in the preview download unless it has the same domain, https://pictureit.co !=  https://cdn.pictureit.co.
  # currently using cdn.pictureit.co, which is breaking
  def proxied_bg_images
    bg_images = background_collection.bg_images
    url_length = BASE_URL.length
    bg_images.each do |i|
      next if i['src'][0..url_length-1] == BASE_URL
      ip = ImageProxy.find_or_create_by(src: i['src'])
      i['src'] = ip.url
    end
    bg_images
  end

  def preview_count
    Event.products.where(object_id: self.id).count
  end

  def cached_widget_product_data
    product = self

    if (!enabled || is_use_parent_image?) &&
       is_variant &&
       (parent_product = CacheManager::Product.cached_product_by_external_product(product.product_id) || parent) &&
       parent_product.enabled

        if !enabled
          product = parent_product
        else # is_use_parent_image?
          product.image_url = parent_product.image_url
        end
    end

    CacheManager::Product.new(product).cached_widget_product_data
  end

  def update_status_of_local_shopify_product
    local_shopify_product&.update(
      status: enabled? ? LocalShopifyProduct.statuses[:activated] : LocalShopifyProduct.statuses[:deactivated]
    )
  end

  def copy_image_to_cdn(purge = false)
    return unless image_url && image_url.exclude?('pictureit.co') && ENV.fetch("IS_USING_CDN") { true }.to_b
    ext = image_url.split('?')[0].split('.').last
    file = URI.open(image_url)
    filename = "image-#{SecureRandom.hex(6)}-#{Time.now.to_i}.#{ext}"
    if images.attach(io: file, filename: filename)
      blob_id = images.blobs.find_by(filename: filename).id
      new_url = friendly_url(images.find_by(blob_id: blob_id))
      update(image_url: new_url) # update_column

      CacheManager::Product.new(self).purge_cache if purge
    end
  end

  def copy_image_to_cdn_with_delay
    CopyProductImageToCdnJob.perform_later(self.id)
  end

  def recalculate_product_variants_count
    Product.reset_counters(id, :product_variants)
  end

  def recalculate_enabled_product_variants_count
    parent_product = parent || self
    parent_product.update_columns(enabled_product_variants_count: parent_product.enabled_product_variants.count)
  end

  def generate_image_variant(product_image)
    product_image.variant(resize_to_limit: [1080, 1080]).processed
  end

  private

  def purge_gltf_file_and_usdz_file
    gltf_file.purge_later
    usdz_file.purge_later
  end

  # Recalculate the product_variants_count for only parent products
  def self.recalculate_product_variants_count
    only_parents.find_each do |product|
      product.recalculate_product_variants_count
    end
  end

  # Recalculate the enabled_product_variants_count for only parent products
  def self.recalculate_enabled_product_variants_count
    only_parents.find_each do |product|
      product.recalculate_enabled_product_variants_count
    end
  end
end

# == Schema Information
#
# Table name: products
#
#  id                             :bigint           not null, primary key
#  dimensions_unit                :string           default("inches")
#  enabled                        :boolean          default(FALSE)
#  enabled_product_variants_count :integer          default(0), not null
#  featured_image_processed_at    :datetime
#  has_variants                   :boolean          default(FALSE)
#  height                         :float
#  image_url                      :string
#  is_use_parent_image            :boolean          default(FALSE)
#  meta                           :jsonb
#  preview_count_cache            :bigint           default(0)
#  product_variants_count         :integer          default(0), not null
#  title                          :text
#  variants_ids                   :jsonb
#  width                          :float
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  background_collection_id       :bigint
#  external_id                    :text
#  parent_id                      :bigint
#  shop_id                        :bigint           not null
#
# Indexes
#
#  index_products_on_external_id              (external_id)
#  index_products_on_parent_id                (parent_id)
#  index_products_on_shop_id                  (shop_id)
#  index_products_on_shop_id_and_external_id  (shop_id,external_id)
#
# Foreign Keys
#
#  fk_rails_...  (shop_id => shops.id)
#
