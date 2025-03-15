class BackgroundCollection < ApplicationRecord
  belongs_to :shop
  before_create :set_name
  
  def set_name
    count = shop.background_collections.count + 1
    self.name = "Background Collection ##{count}"
  end
end

# == Schema Information
#
# Table name: background_collections
#
#  id         :bigint           not null, primary key
#  bg_images  :jsonb
#  default    :boolean          default(FALSE)
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  shop_id    :bigint
#
# Indexes
#
#  index_background_collections_on_shop_id  (shop_id)
#
