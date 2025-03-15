class AppSettings

  WIDGET_EXPOSED_ATTRIBUTES = [
    :preferences,
    :client_id,
    :shopify_domain,
    :autoscale,
    :language,
    :preview_type,
    :plan_name
  ].freeze

  def initialize(shop)
    @shop = shop
  end

  def settings
    @shop.as_json(only: WIDGET_EXPOSED_ATTRIBUTES).merge(mergable_attributes)
  end

  private 

  def mergable_attributes
    {
      env: Rails.env.chars[0],
      api_url: api_url,
      proxy_url: proxy_url,
      cdn_url: cdn_url,
    }
  end

  def api_url
    "#{BASE_URL}"
  end

  def proxy_url
    "#{BASE_URL}"
  end

  def cdn_url
    Rails.application.credentials.cdn_url
  end
end