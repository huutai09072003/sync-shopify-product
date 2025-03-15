class PlanSerializer < ApplicationSerializer
  attributes :id,
             :name,
             :price,
             :shop_id,
             :price_pioneer

  has_many :features, serializer: FeatureSerializer

  def price
    (object.price.to_f / 100).round(2)
  end

  def price_pioneer
    (object.price_pioneer.to_f / 100).round(2)
  end
end
