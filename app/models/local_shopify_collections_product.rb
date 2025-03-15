class LocalShopifyCollectionsProduct < ApplicationRecord
  belongs_to :local_shopify_collection, primary_key: :original_id
  belongs_to :local_shopify_product, primary_key: :original_id
end

# == Schema Information
#
# Table name: local_shopify_collections_products
#
#  id                          :bigint           not null, primary key
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  local_shopify_collection_id :string           not null
#  local_shopify_product_id    :string           not null
#
# Indexes
#
#  index_local_shopify_collection_and_product_id  (local_shopify_collection_id,local_shopify_product_id) UNIQUE
#  index_local_shopify_collection_id              (local_shopify_collection_id)
#  index_local_shopify_product_id                 (local_shopify_product_id)
#
