## SHOPS

shop_params = {
  "cta_text"=>"Live Preview",
  "cta_bg_color"=>"purple",
  "cta_text_color"=>"#fff",
  "email_notifications"=>true,
  "first_name"=>nil,
  "last_name"=>nil,
  "vanity_domain"=>"superpose-demo.myshopify.com",
  "shopify_domain"=>"superpose-demo.myshopify.com",
  "shopify_token"=>"fb968309c88af281f62a6d302885aef8",
  "store_name"=>"Superpose Demo",
  "admin_email"=>"invest@forkequity.com",
  "client_id"=> nil, # created automatically
  "preferences"=> {
    "cta_text"=>"Live Preview",
    "cta_bg_color"=>"purple",
    "cta_text_color"=>"#fff",
    "email_notifications"=>true
  }
}

shop = Shop.find_by(shopify_domain: shop_params['shopify_domain'])
shop = Shop.create!(shop_params) if shop.nil?
shop.update(client_id: 'mDHSk9VpN6rkXznbednsLg') # stay in sync w/ planted script tag

## PRODUCTS

# product_params = {
#   "tags"=>"",
#   "title"=>"Starry Night",
#   "handle"=>"starry-night",
#   "vendor"=>"Superpose Demo",
#   "body_html"=>"decent painting. a bit rushed.",
#   "product_type"=>"painting",
#   "published_scope"=>"web",
#   "template_suffix"=>nil,
#   "external_id"=>"4115516260387",
#   "featured_image_absolute_url"=>
#   "https://cdn.shopify.com/s/files/1/0265/7130/9091/products/starry-night.jpg?v=1569225784",
#   "featured_image_processed_at" => Time.now,
#   "width"=>62.5,
#   "width_unit"=>"inches",
#   "height"=>40.0,
#   "height_unit"=>"inches",
#   "enabled"=>true,
#   "meta"=>{
#     "tags"=>"",
#     "title"=>"Starry Night",
#     "handle"=>"starry-night",
#     "vendor"=>"Superpose Demo",
#     "body_html"=>"decent painting. a bit rushed.",
#     "product_type"=>"painting",
#     "published_scope"=>"web",
#     "template_suffix"=>nil
#   }
# }
#
# product = Product.find_by(external_id: product_params['external_id'])
# Product.create!(product_params.merge('shop_id' => shop.id)) if product.nil?
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?