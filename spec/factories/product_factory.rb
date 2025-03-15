FactoryBot.define do
  factory :product do
    external_id { '4115516260387' }
    title { 'Starry Night' }
    width { 42.25 }
    dimensions_unit { 'inches' }
    height { 30.5 }
    image_url { '/static/starry-night-framed.jpg' }
    enabled { true }
    shop
  end
end
