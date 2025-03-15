class WidgetJsSettings

  WIDGET_EXPOSED_ATTRIBUTES = [
    :client_id,
    :shopify_domain,
    :preview_type,
    :hide_branding_promotion
  ].freeze

  def initialize(shop)
    @shop = shop
  end

  def settings
    @shop.as_json(only: WIDGET_EXPOSED_ATTRIBUTES)
      .merge(mergable_attributes)
      .merge(preferences: whitelisted_preferences)
  end

  private

  def whitelisted_preferences
    @shop.preferences.slice('cta_text', 'cta_bg_color', 'cta_text_color', 'cta_position', 'cta_size', 'cta_rounded', 'cta_show_image', 'cta_drop_shadow', 'cta_animation','hide_branding_promotion', 'custom_css', 'enable_variants', 'preview_show_full_background')
  end

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