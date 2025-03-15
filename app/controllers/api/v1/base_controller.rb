class Api::V1::BaseController < AuthenticatedController
  skip_before_action :verify_authenticity_token
  before_action :underscore_params!
  prepend_before_action :authenticate_admin_user!, if: :is_impersonate

  def pagination_meta(collection)
    return unless collection

    {
      current_page: collection.page,
      next_page: collection.next,
      prev_page: collection.prev,
      total_pages: collection.pages,
      displaying_info: {
        from: collection.from,
        to: collection.to
      },
      total_count: collection.count
    }
  end

  def transform_response(value, options = {})
    ActiveModelSerializers::Adapter::Base.transform_key_casing!(value.as_json, options)
  end

  def shopify_host
    @shopify_host ||= request.headers['Shopify-Host']
  end

  private

  def is_impersonate
    return @is_impersonate if defined?(@is_impersonate)

    @is_impersonate = request.headers['Is-Impersonate'] == '1' && session[:impersonate] == '1'
  end

  def login_again_if_different_user_or_shop
    if is_impersonate
      if session[:shop_id].blank? || session[:shop_id].to_s != request.headers['Shop-Id']
        render json: { error: 'You are logged with another shop.' }, status: :unauthorized
      end
    else
      super
    end
  end

  def current_shopify_session
    if is_impersonate
      @current_shopify_session ||= ShopifyApp::SessionRepository.retrieve_shop_session(session[:shop_id])
    else
      super
    end
  end

  def underscore_params!
    # must be run 'request.params.deep_transform_keys!(&:underscore)' before 'params.transform_keys!(&:underscore)'
    request.params.deep_transform_keys!(&:underscore)
    params.transform_keys!(&:underscore)
  end
end
