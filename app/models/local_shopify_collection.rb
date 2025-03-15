class LocalShopifyCollection < ApplicationRecord
  has_many :local_shopify_collections_products, primary_key: :original_id, dependent: :destroy
  has_many :local_shopify_products, through: :local_shopify_collections_products

  belongs_to :shop
end

# == Schema Information
#
# Table name: local_shopify_collections
#
#  id          :bigint           not null, primary key
#  description :text
#  handle      :text
#  title       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  original_id :string
#  shop_id     :bigint
#
# Indexes
#
#  index_local_shopify_collections_on_original_id  (original_id) UNIQUE
#  index_local_shopify_collections_on_shop_id      (shop_id)
#
