module ApplicationHelper
  include Pagy::Frontend

  def active_tab(matcher)
    if (request.env['REQUEST_PATH'] == matcher)
      'is-active'
    elsif (request.env['REQUEST_PATH'].include?(matcher) && matcher != '/')
      'is-active'
    end
  end

  def preview_product_url(product, shop = @shop)
    "https://#{shop.vanity_domain}/products/#{product.handle}?show-picture-it-preview=on"
  end
end
