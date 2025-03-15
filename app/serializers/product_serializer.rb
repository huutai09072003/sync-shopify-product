class ProductSerializer < ApplicationSerializer
  include ApplicationHelper

  attributes :id,
             :shop_id,
             :external_id,
             :is_variant,
             :title,
             :enabled,
             :preview_count,
             :background_collection_id,
             :dimensions_unit,
             :is_use_parent_image,
             :width,
             :height

  attribute :image_url do
    object.image_url || object.image
  end

  attribute :preview_product_url do
    preview_product_url(object, Current.shop)
  end

  attribute :preview_count do
    object.preview_count_cache
  end
end
