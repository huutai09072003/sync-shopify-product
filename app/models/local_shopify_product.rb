class LocalShopifyProduct < ApplicationRecord
  ORIGINAL_DATA_ATTRIBUTES = %w[id title status handle images variants].freeze

  attr_accessor :custom_preview_count
  serialize :original_data, Hash
  serialize :variant_ids, Array

  belongs_to :shop

  has_one :product, class_name: 'Product', foreign_key: :external_id, primary_key: :original_id, dependent: :destroy, inverse_of: :local_shopify_product

  has_many :local_shopify_collections_products, primary_key: :original_id, dependent: :destroy
  has_many :local_shopify_collections, through: :local_shopify_collections_products

  enum status: { activated: 'activated', deactivated: 'deactivated' }

  validates :original_id, presence: true, uniqueness: true
  validates :original_data, presence: true

  scope :with_original_id, ->(original_id) { where(original_id: original_id) }
  scope :with_shop_id, ->(shop_id) { where(shop_id: shop_id) }
  scope :without_shop_id, ->(shop_id) { where.not(shop_id: shop_id) }
  scope :with_vendor_not_nil, -> { where.not(vendor: nil) }

  class << self
    def sort_products_by_preview_count_descending(products)
      products.sort_by { |product| -product.custom_preview_count }
    end
  end

  ORIGINAL_DATA_ATTRIBUTES.each do |attribute|
    define_method("original_data_#{attribute}") do
      original_data[attribute]
    end
  end

  def original_data_image
    (original_data_images || []).first
  end

  def handle
    original_data_handle
  end

  def preview_count
    if custom_preview_count.present?
      custom_preview_count
    else
      super
    end
  end

  def original_data_status_active?
    original_data_status.downcase == "active"
  end

  def original_shopify_product
    PictureItShopifyApi::Product.find(original_id, session: shop.shopify_session, fields: ["id", "title", "handle", "status",
                                                                                            :images=> {
                                                                                              fields: ["id", "src"],
                                                                                              limit: 100
                                                                                            },
                                                                                            :variants=> {
                                                                                              fields: ["id", "title"],
                                                                                              limit: 100
                                                                                            }
                                                                                          ])
  end
end

# == Schema Information
#
# Table name: local_shopify_products
#
#  id            :bigint           not null, primary key
#  original_data :text
#  preview_count :bigint           default(0)
#  status        :string
#  title         :string
#  variant_ids   :text
#  vendor        :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  original_id   :string
#  shop_id       :bigint
#
# Indexes
#
#  index_local_shopify_products_on_original_id  (original_id) UNIQUE
#  index_local_shopify_products_on_shop_id      (shop_id)
#
