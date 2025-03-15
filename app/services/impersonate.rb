class Impersonate

  def self.login_as(session, shop)
    session[:shopify] = nil
    session[:shop_id] = nil
    session[:shopify_domain] = nil
    session[:shopify_user] = nil

    session[:impersonate] = '1'

    shopify_session = shop.shopify_session
    session[:shop_id] = ShopifyApp::SessionRepository.store_shop_session(shopify_session)
    session[:shopify_domain] = shop.shopify_domain
  end

end
