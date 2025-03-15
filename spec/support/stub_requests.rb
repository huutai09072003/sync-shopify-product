def stub_shopify_requests(shopify_domain, shopify_token, client_id)

  allow_any_instance_of(ShopifyAPI::Webhook).to receive(:persisted?).and_return(true) # skips: (ShopifyApp::WebhooksManager::CreationFailed)
  allow_any_instance_of(ShopifyApp::ScripttagsManager).to receive(:create_scripttags).and_return(true) # skips: (ShopifyApp::ScripttagsManager::CreationFailed)

  # Webhooks
  stub_request(:get, "https://#{shopify_domain}/admin/api/#{api_version}/webhooks.json").with(headers: shopify_headers(shopify_token))
    .to_return(status: 200, body: {}.to_json, headers: {})

  stub_request(:put,"https://#{shopify_domain}/admin/api/#{api_version}/webhooks/.json").with(
    body: "{\"webhook\":{\"format\":\"json\",\"topic\":\"products/delete\",\"address\":\"http://127.0.0.1:3055/webhooks/products_delete\"}}",
    headers: shopify_headers(shopify_token))
    .to_return(status: 200, body: "", headers: {})

  stub_request(:put, "https://#{shopify_domain}/admin/api/#{api_version}/webhooks/.json").with(
    body: "{\"webhook\":{\"format\":\"json\",\"topic\":\"app/uninstalled\",\"address\":\"http://127.0.0.1:3055/webhooks/app_uninstalled\"}}",
    headers: shopify_headers(shopify_token))
    .to_return(status: 200, body: "", headers: {})

  # ScriptTags
  stub_request(:post, "https://#{shopify_domain}/admin/api/#{api_version}/script_tags.json").with(
    body: "{\"script_tag\":{\"format\":\"json\",\"event\":\"onload\",\"src\":\"http://127.0.0.1:3055/js/#{client_id}/load.js\"}}",
    headers: shopify_headers(shopify_token))
    .to_return(status: 200, body: {}.to_json, headers: {})

  stub_request(:get, "https://#{shopify_domain}/admin/api/#{api_version}/script_tags.json").with(headers: shopify_headers(shopify_token))
    .to_return(status: 200, body: {}.to_json, headers: {})

  stub_request(:get, "https://#{shopify_domain}/admin/api/#{api_version}/script_tags.json").with(headers: shopify_headers(shopify_token))
    .to_return(status: 200, body: {}.to_json, headers: {})

  # Shop
  # ------------------------------ #
  stub_request(:get, "https://#{shopify_domain}/admin/api/#{api_version}/shop.json").with(headers: shopify_headers(shopify_token))
    .to_return(status: 200, body: json_fixture('shops/index', { 'shop' => { 'myshopify_domain': shopify_domain } }), headers: {})


  # RecurringApplicationCharge
  # ------------------------------ #
  stub_request(:get, "https://#{shopify_domain}/admin/api/#{api_version}/recurring_application_charges.json").with(headers: shopify_headers(shopify_token))
    .to_return(status: 200, body: json_fixture('recurring_application_charges/index'), headers: {})


  # Product
  # ------------------------------ #
  stub_request(:get, "https://#{shopify_domain}/search?page=1&q=*&view=picture-it").with(headers: public_liquid_headers).
     to_return(status: 200, body: "", headers: {})

  stub_request(:get, "https://#{shopify_domain}/admin/api/#{api_version}/themes.json").with(headers: shopify_headers(shopify_token))
    .to_return(status: 200, body: json_fixture('themes/index'), headers: {})

  stub_request(:get, "https://#{shopify_domain}/admin/api/#{api_version}/themes/828155753/assets.json?asset%5Bkey%5D=templates/search.picture-it.liquid&theme_id=828155753").with(headers: shopify_headers(shopify_token))
    .to_return(status: 200, body: json_fixture('themes/template'), headers: {})

  stub_request(:get, "https://#{shopify_domain}/admin/api/#{api_version}/products.json").with(headers: shopify_headers(shopify_token))
    .to_return(status: 200, body: json_fixture('products/index'), headers: {})

  stub_request(:get, "https://#{shopify_domain}/admin/api/#{api_version}/products.json?fields=id,handle,image,title,variants,vendor,sku&limit=50").with(headers: shopify_headers(shopify_token))
    .to_return(status: 200, body: json_fixture('products/index'), headers: {})

  stub_request(:get, "https://#{shopify_domain}/admin/api/#{api_version}/products.json?limit=15").with(headers: shopify_headers(shopify_token))
    .to_return(status: 200, body: json_fixture('products/index'), headers: {})

  stub_request(:get, "https://#{shopify_domain}/admin/api/#{api_version}/products.json?handle=ipod-nano").with(headers: shopify_headers(shopify_token))
    .to_return(status: 200, body: json_fixture('products/single'), headers: {})

  stub_request(:get, "https://#{shopify_domain}/admin/api/#{api_version}/products.json?handle=test").with(headers: shopify_headers(shopify_token))
    .to_return(status: 200, body: json_fixture('products/single'), headers: {})

  stub_request(:get, "https://#{shopify_domain}/admin/api/#{api_version}/products.json?handle=nano-ipad").with(headers: shopify_headers(shopify_token))
    .to_return(status: 200, body: json_fixture('products/single_2'), headers: {})

  stub_request(:get, /https:\/\/#{shopify_domain}\/admin\/api\/#{api_version}\/products\.json\?handle=(.*|\S*)/).with(headers: shopify_headers(shopify_token))
    .to_return(status: 200, body: json_fixture('products/single'), headers: {})

  stub_request(:get, /https:\/\/#{shopify_domain}\/admin\/api\/#{api_version}\/products\/\d+.json/).with(headers: shopify_headers(shopify_token))
    .to_return(status: 200, body: json_fixture('products/product'), headers: {})

  stub_request(:get, "https://#{shopify_domain}/admin/api/#{api_version}/products/count.json").with(headers: shopify_headers(shopify_token))
    .to_return(status: 200, body: json_fixture('products/count'), headers: {})

end

def shopify_headers(shopify_token)
  {
    'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    'User-Agent'=>'ShopifyAPI/9.5.1 ActiveResource/6.0.0 Ruby/3.1.2 | ShopifyApp/18.1.3',
    'X-Shopify-Access-Token'=> shopify_token
  }
end

def post_shopify_headers(shopify_token)
  shopify_headers(shopify_token).merge('Accept'=>'*/*')
end

def public_liquid_headers
  {
    'Accept'=>'*/*',
    'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    'User-Agent'=>'Ruby'
  }
end

def api_version
  ShopifyApp.configuration.api_version
end
