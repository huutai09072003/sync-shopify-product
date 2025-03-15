class Api::V1::ShopsController < Api::V1::BaseController
  def show
    @shop.update_shopify_shop_id if @shop.shopify_shop_id.blank?

    SyncDataFromShopifyToLocalJob.perform_later(@shop.id)

    render json: @shop, serializer: ShopSerializer
  end

  def update
    if @shop.update(shop_params)
      CacheManager::Shop.new(@shop).purge_cache
      render json: @shop, serializer: ShopSerializer
    else
      render json: @shop.errors, status: :unprocessable_entity
    end
  end

  def paid_in_good_standing # using approved_charge instead of paid_in_good_standing? for improved LCP performance
    is_paid_in_good_standing = @shop.paid_in_good_standing?

    @shop.update(approved_charge: is_paid_in_good_standing) if is_paid_in_good_standing != @shop.approved_charge?

    render json: transform_response({ is_paid_in_good_standing: is_paid_in_good_standing })
  end

  private

  def shop_params
    params.permit(
      :email_notifications, :show_background_dimension_warning, :enable_variants,
      :cta_text, :cta_bg_color,
      :cta_text_color, :cta_position, :cta_size, :cta_show_image, :cta_rounded,
      :cta_drop_shadow, :cta_animation, :custom_css, :language, :preview_type,
      :preivew_add_drop_shadow, :preview_show_full_background, :autoscale, :hide_branding_promotion,
      :hide_onboarding,
      bg_images: [:order, :src, :width_in_mm, :paintable])
  end
end
