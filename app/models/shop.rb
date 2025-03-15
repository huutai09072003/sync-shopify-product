class Shop < ApplicationRecord
  include ShopifyApp::ShopSessionStorageWithScopes
  include Preferenceable
  include Chargeable
  include LocalShopifyProductable
  include Productable
  include ShopChannelable
  include LocalShopifyCollectionable

  serialize :local_shopify_product_original_ids_that_is_activating_product, Array

  jsonb_accessor :preferences, PREFERENCES_ATTRIBUTES
  has_token token_attribute: :client_id, length: 24
  validates_presence_of :shopify_domain

  has_many :local_shopify_products, dependent: :destroy
  has_many :local_shopify_collections, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :plans, dependent: :destroy
  has_many :parent_products, -> { only_parents }, class_name: 'Product'
  has_one :media_library
  has_many :background_collections
  after_create :create_media_library, :set_initial_bg_images, :update_chart_data_cache, :update_shopify_shop_id, :create_plans_with_features
  after_commit :sync_data_from_shopify_to_local, on: :create

  enum preview_type: {
    ar_preview_only: "ar_preview_only",
    showroom_and_ar: "showroom_and_ar",
    virtual_showroom_only: "virtual_showroom_only"
  }, _prefix: true

  def sync_data_from_shopify_to_local
    SyncDataFromShopifyToLocalJob.perform_later(id)
  end

  def create_media_library
    ml = MediaLibrary.new(shop_id: id)
    ml.save(validate: false) # since media library starts empty, must skip validation (attached :true) deployed for content_type restrictions
  end

  def set_initial_bg_images
    # Set the first image from STOCK_IMAGES
    images = [MediaLibrary::STOCK_IMAGES[0].merge(order: 1)]
    background_collections.create(default: true, bg_images: images)
  end

  def update_chart_data_cache
    self.update(chart_data_cache: chart_data)
  end

  def update_shopify_shop_id
    self.update(shopify_shop_id: shopify_shop.id)
  end

  def shopify_shop
    PictureItShopifyApi::Shop.current(session: shopify_session, fields: ['id'])
  end

  def admin_url_on_shopify
    "https://#{shopify_domain}/admin"
  end

  def default_background_collection
    bg_collection = background_collections.find_by(default: true)
    bg_collection = background_collections.first unless bg_collection
    bg_collection
  end

  def api_version
    ShopifyApp.configuration.api_version
  end

  def after_charge_accepted_tasks
    handle_branding_promotion
    handle_loops_contact unless Rails.env.development?
  end

  def handle_branding_promotion
    update(hide_branding_promotion: true) if plan_name.include?(no_branding_name)
  end

  def shopify_session
    @shopify_session ||= ShopifyAPI::Auth::Session.new(shop: shopify_domain, access_token: shopify_token)
  end

  def shopify_product_count
    @shopify_product_count ||= PictureItShopifyApi::ProductsCount.count_active(session: shopify_session)
  end

  def shopify_collection_count
    @shopify_product_collection_count ||= PictureItShopifyApi::CollectionsCount.count(session: shopify_session)
  end

  def activated_product_count
    @activated_product_count ||= local_shopify_products.activated.count
  end

  def deactivated_product_count
    @deactivated_local_shopify_product_count ||= shopify_product_count - activated_product_count
  end

  def cached_shopify_product_count
    CacheManager::Shop.new(self).cached_shopify_product_count
  end

  # TODO: find a better way to do this. when user uploads custom background image, it can't be used in the preview download unless it has the same domain, https://pictureit.co !=  https://cdn.pictureit.co.
  # currently using cdn.pictureit.co, which is breaking
  def proxied_bg_images
    url_length = BASE_URL.length
    bg_images.each do |i|
      next if i['src'][0..url_length-1] == BASE_URL
      ip = ImageProxy.find_or_create_by(src: i['src'])
      i['src'] = ip.url
    end
    bg_images
  end

  # Input date - products added to shop after this date if not added it will use last month
  # width, height, unit keys - if store have metafields with width / height / unit, just enter name of it and it will map through it
  #
  # Example to run in console:
  # shop = Shop.find_by(vanity_domain: 'matevz-dev.myshopify.com')
  # shop.activate_all_products('31 Jan 2022 09:30:15 -0400', 'width', 'height', 'unit')
  def activate_all_products(input_date = nil, width_key = nil, height_key = nil, unit_key = nil)
    if (input_date)
      date = input_date
      date = date.to_datetime
    else
      date = DateTime.now() - 1.month
    end
    date = date&.strftime('%Y-%m-%dT%H:%M:%SZ')

    shopify_products = PictureItShopifyApi::Product.all(
      session: shopify_session,
      filter: {status: 'ACTIVE', created_at: ">=#{date}"},
      pagination: {limit: 250}
    ).data

    shopify_products.each do |shopify_product|
      next if check_if_product_exists?(shopify_product.id)

      active_product(
        shopify_product,
        metafield_keys: { width_key: width_key, height_key: height_key, unit_key: unit_key }
      )
    end
  end

  # ex: Shop ID 1268, collection_id = 81538744413 # 'plakater'
  # note: Shopify API does not allow fetching a collection ID by name, OR fetching all collection IDs; use 'view-source:' on desired collection page to find id
  def activate_products_by_collection(collection_id, width_key = nil, height_key = nil, unit_key = nil)
    begin
      shopify_products = PictureItShopifyApi::Collection.find(collection_id, session: shopify_session).products
      shopify_products = shopify_products.select { |p| p.status == "ACTIVE" }

      shopify_products.each do |shopify_product|
        next if check_if_product_exists?(shopify_product.id)

        active_product(
          shopify_product,
          metafield_keys: { width_key: width_key, height_key: height_key, unit_key: unit_key }
        )
      end

      "Imported collection #{collection_id}"
    rescue StandardError => e
      return "Collection #{collection_id} not found"
    end
  end

  def remove_products_by_tag(tags_to_exclude, test = false) # tags_to_exclude should be Array
    all_products = self.products
    tags_to_exclude.map!(&:downcase) # downcase to normalize

    products_to_remove = 0
    all_products.each do |product|
      tags = product.tags.downcase.split(', ') # downcase and sanitize
      tag_found = false

      tags.each do |tag|
        tag_found = true if tags_to_exclude.include?(tag)
      end

      if tag_found
        products_to_remove += 1
        product.destroy unless test
      end
    end

    "#{test ? 'WOULD (test) remove' : 'Removed'} #{products_to_remove} products"
  end

  def product_created_date; end # required for active_admin 'import by created date' datepicker

  def base_admin_api_url
    "https://#{shopify_domain}/admin/api/#{ShopifyApp.configuration.api_version}"
  end

  def collections_url
    "#{base_admin_api_url}/collects.json?limit=250&access_token=#{shopify_token}"
  end

  def custom_collections_url
    "#{base_admin_api_url}/custom_collections.json?limit=250&access_token=#{shopify_token}"
  end

  def chart_data
    product_ids = products.pluck(:id)
    live_previews = Event.last_90_days.previews.with_object_id(product_ids)
    downloads = Event.last_90_days.downloads.with_object_id(product_ids)
    uploads = Event.last_90_days.uploads.with_object_id(product_ids)

    {
      live_previews: {
        count: live_previews.count,
        data: live_previews.group_by_day(:created_at).count
      },
      downloads: {
        count: downloads.count,
        data: downloads.group_by_day(:created_at).count
      },
      uploads: {
        count: uploads.count,
        data: uploads.group_by_day(:created_at).count
      }
    }
  end

  def reloading_local_shopify_products
    reloading_local_shopify_products_at.present? && reloading_local_shopify_products_at > 1.hour.ago
  end

  def deleting_local_shopify_products
    deleting_local_shopify_products_at.present? && deleting_local_shopify_products_at > 1.hour.ago
  end

  def reloading_local_shopify_collections
    reloading_local_shopify_collections_at.present? && reloading_local_shopify_collections_at > 1.hour.ago
  end

  def deleting_local_shopify_collections
    deleting_local_shopify_collections_at.present? && deleting_local_shopify_collections_at > 1.hour.ago
  end

  def scheduled_reload_local_shopify_products
    will_reload_local_shopify_products_at.present? && will_reload_local_shopify_products_at > Time.current
  end

  def scheduled_reload_local_shopify_collections
    will_reload_local_shopify_collections_at.present? && will_reload_local_shopify_collections_at > Time.current
  end

  def bulk_activating_products
    bulk_activating_products_at.present? && bulk_activating_products_at > 20.minutes.ago
  end

  def local_shopify_product_original_ids_that_is_activating_product
    return [] unless bulk_activating_products

    super
  end

  def create_plans_with_features
    create_starter_plan
    create_professional_plan
  end

  def create_starter_plan
    starter_plan = Plan.create!(name: "Starter", price: 1900, shop: self, price_pioneer: 1500)
    create_showroom_feature(starter_plan)
  end

  def create_professional_plan
    professional_plan = Plan.create!(name: "Professional", price: 2900, shop: self, price_pioneer: 2200)
    create_showroom_feature(professional_plan)
  end

  def create_showroom_feature(plan)
    Feature.create!(name: "Showroom", price: 400, plan: plan)
  end

  private

  def handle_loops_contact
    LoopsContact::HandleAudience.new(self).handle_contact
  end

  def check_if_product_exists?(external_id)
    products.find_by(external_id: id).present?
  end
end

# == Schema Information
#
# Table name: shops
#
#  id                                                            :bigint           not null, primary key
#  access_scopes                                                 :string           default(""), not null
#  admin_email                                                   :string
#  approved_charge                                               :boolean          default(FALSE)
#  autoscale                                                     :boolean
#  bg_images                                                     :jsonb
#  bulk_activating_products_at                                   :datetime
#  charge_name                                                   :string
#  charge_price                                                  :string
#  charge_status                                                 :string
#  chart_data_cache                                              :jsonb
#  cta_animation                                                 :string           default("none")
#  cta_drop_shadow                                               :boolean          default(FALSE)
#  custom_css                                                    :text
#  deleting_local_shopify_collections_at                         :datetime
#  deleting_local_shopify_products_at                            :datetime
#  first_name                                                    :string
#  hide_onboarding                                               :boolean          default(FALSE), not null
#  language                                                      :string           default("en")
#  last_name                                                     :string
#  local_shopify_product_original_ids_that_is_activating_product :text
#  plan_name                                                     :string
#  preferences                                                   :jsonb
#  preview_type                                                  :string           default("showroom_and_ar")
#  product_count                                                 :integer
#  reloading_local_shopify_collections_at                        :datetime
#  reloading_local_shopify_products_at                           :datetime
#  shopify_debug                                                 :boolean          default(FALSE)
#  shopify_domain                                                :string           not null
#  shopify_token                                                 :string           not null
#  store_name                                                    :string
#  vanity_domain                                                 :string
#  will_reload_local_shopify_collections_at                      :datetime
#  will_reload_local_shopify_products_at                         :datetime
#  created_at                                                    :datetime         not null
#  updated_at                                                    :datetime         not null
#  client_id                                                     :string
#  shopify_shop_id                                               :string
#
# Indexes
#
#  index_shops_on_shopify_domain   (shopify_domain) UNIQUE
#  index_shops_on_shopify_shop_id  (shopify_shop_id)
#
