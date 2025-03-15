FactoryBot.define do
  factory :shop do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    admin_email { Faker::Internet.email }
    store_name { Faker::Company.name }
    vanity_domain { 'superposestore.com'}
    shopify_domain { 'superpose-demo.myshopify.com' }
    shopify_token { 'qwertyuiopasdfghjkl'}
    client_id { nil } # created automatically
  end
end
