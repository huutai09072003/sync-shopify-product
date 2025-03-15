require 'rails_helper'

feature "create background collection", :js => true do
  before do
    @shop = create(:shop)
    stub_shopify_requests(@shop.shopify_domain, @shop.shopify_token, @shop.client_id)
    login_as(@shop)
  end

  scenario "create and back to index" do
    find('.o-nav li a', text: 'Backgrounds').click # go to background index

    expect(page).to have_text('Background Collection #1') # inital created bg collection

    find('.o-button', text: 'New Collection').click

    find('.o-button', text: 'Add Collection').click

    expect(page).to have_text("Background collection can't be saved without any image added.")

    page.all('.media-gallery--selectable .media-gallery__item')[0].find('.image-wrapper').click

    page.all('.media-gallery--selectable .media-gallery__item')[3].find('.image-wrapper').click

    page.all('.media-gallery--selectable .media-gallery__item')[6].find('.image-wrapper').click

    sleep(1)

    find('.o-button', text: 'Add Collection').click

    sleep(1)

    expect(@shop.background_collections.reload.last.bg_images.count).to eq(3)

    # find('a.o-breadcrumbs__button.is-active').click
    expect(page).to have_text('Background Collection #2')
  end
end
