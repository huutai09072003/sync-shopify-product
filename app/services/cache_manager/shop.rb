class CacheManager::Shop
  attr_accessor :shop

  def initialize(shop)
    @shop = shop
  end

  def purge_cache
    purge_cached_shopify_product_count
    purge_cloudflare_cache
  end

  def cached_shopify_product_count
    Rails.cache.fetch("#{shop.shopify_domain}/shopify_product_count", expires_in: 10.minutes) do
      shop.shopify_product_count
    end
  end

  def purge_cached_shopify_product_count
    Rails.cache.delete("#{shop.shopify_domain}/shopify_product_count")
  end

  def purge_cloudflare_cache
    return unless Rails.env.production?

    # Bacon solution
    # zone_id = Rails.application.credentials.cloudflare[:zone_id]
    # email = Rails.application.credentials.cloudflare[:email]
    # token = Rails.application.credentials.cloudflare[:token]

    zone_id = ENV['CLOUDFLARE_ZONE_ID']
    email = ENV['CLOUDFLARE_EMAIL']
    token = ENV['CLOUDFLARE_TOKEN']

    url = "https://pictureit.co/js/#{shop.client_id}/load.js?shop=#{shop.shopify_domain}"

    puts "purge url = #{url}"

    response = HTTParty.delete(
      "https://api.cloudflare.com/client/v4/zones/#{zone_id}/purge_cache",
      headers: {
        'X-Auth-Email' => email,
        'X-Auth-Key' => token,
        'Content-Type' => 'application/json'
      },
      body: { files: [url] }.to_json
    )

    if response.body['success']
      puts 'Done clearing cache!'
    else
      puts "Error clearing cache! - #{shop.id}"
    end
  end
end
