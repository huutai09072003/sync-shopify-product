class LocalShopifyCollectionSerializer < ApplicationSerializer
  include ApplicationHelper

  attributes :id,
             :title,
             :original_id
end
