class ShopSerializer < ApplicationSerializer
  attributes :id,
             :first_name,
             :last_name,
             :language,
             :preview_type,
             :autoscale,
             :show_background_dimension_warning,
             :email_notifications,
             :enable_variants,
             :cta_text,
             :cta_bg_color,
             :cta_text_color,
             :cta_position,
             :cta_size,
             :cta_rounded,
             :cta_drop_shadow,
             :cta_show_image,
             :cta_animation,
             :preivew_add_drop_shadow,
             :preview_show_full_background,
             :hide_branding_promotion,
             :custom_css,
             :bg_images,
             :product_count,
             :admin_url_on_shopify,
             :bulk_activating_products,
             :hide_onboarding,
             :local_shopify_product_original_ids_that_is_activating_product,
             :plan_name,
             :charge_name,
             :created_at

  attribute :shopify_product_count do
    object.shopify_product_count
  end

  attribute :activated_product_count do
    object.activated_product_count
  end

  attribute :deactivated_product_count do
    object.deactivated_product_count
  end

  attribute :link_to_add_preview_button_as_theme_app_block do
    "#{object.admin_url_on_shopify}/admin/themes/current/editor?previewPath=/products/#{object.local_shopify_products.first&.handle}"
  end

  attribute :deep_link_to_add_preview_button_as_theme_app_block do
    "#{object.admin_url_on_shopify}/themes/current/editor?template=product&addAppBlockId=#{shopify_preview_id}/live_preview_block&target=mainSection"
  end

  attribute :chart_data do
    object.chart_data_cache || object.chart_data
  end

  attribute :stock_background_collections do
    MediaLibrary::STOCK_IMAGES.as_json
  end

  attribute :product_ids_that_is_removing_the_background_for_the_image do
    []
  end

  attribute :charge_exist do
    !object.charge_status.nil?
  end

  attribute :allowed_trial_days do
    deleted_shops = DeletedShop.where(shopify_domain: object.shopify_domain)
    ineligible = deleted_shops.count >= 2 || (deleted_shops.last && deleted_shops.last.created_at < 24.hours.ago) || !object.charge_status.nil?
    ineligible ? false : true
  end

  private

  def shopify_preview_id
    ENV.fetch("SHOPIFY_LIVE_PREVIEW_ID_#{Rails.env.upcase}", "")
  end
end
