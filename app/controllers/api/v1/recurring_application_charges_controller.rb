class Api::V1::RecurringApplicationChargesController < Api::V1::BaseController
  before_action :skip_charge_if_exists, only: [:create]

  def create
    response = @shop.build_charge(@shop, params[:plan_id], params[:features], params[:discount])

    charge_params = response

    @recurring_application_charge = PictureItShopifyApi::AppSubscription.new
    charge_params.each do |key, value|
      @recurring_application_charge.send("#{key}=", value)
    end

    @recurring_application_charge.return_url = ShopifyAPI::Auth.embedded_app_url(shopify_host) + callback_recurring_application_charge_path(callback_recurring_application_charge_params)

    if @recurring_application_charge.save
      render json: transform_response(
        confirmation_url: @recurring_application_charge.confirmation_url
      ), status: :created
    else
      render json: {
        message: @recurring_application_charge.errors.join(', ')
      }, status: :unprocessable_entity
    end
  end

  private

  def callback_recurring_application_charge_params
    result = {}

    if remove_branding?
      result[:remove_branding] = true
    end

    result
  end

  def remove_branding?
    params[:remove_branding].to_b
  end

  def skip_charge_if_exists
    if @shop.paid_in_good_standing? && !remove_branding?
      render json: { message: "Charge already exists" }, status: :unprocessable_entity
    end
  end
end
