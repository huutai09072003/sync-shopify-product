class Plan < ApplicationRecord
  belongs_to :shop
  has_many :features, dependent: :destroy

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end

# == Schema Information
#
# Table name: plans
#
#  id            :bigint           not null, primary key
#  name          :string           not null
#  price         :integer          not null
#  price_pioneer :integer
#  shop_id       :bigint           not null
#
# Indexes
#
#  index_plans_on_shop_id  (shop_id)
#
# Foreign Keys
#
#  fk_rails_...  (shop_id => shops.id)
#
