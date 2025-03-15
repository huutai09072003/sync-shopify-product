FactoryBot.define do
  factory :deleted_shop do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    admin_email { Faker::Internet.email }
    store_name { Faker::Company.name }
    vanity_domain { 'acmeart.com'}
    shopify_domain { 'acme-art.myshopify.com' }
    shopify_token { 'qwertyuiopasdfghjkl'}
    client_id { SecureRandom.hex(6) }
  end
end
