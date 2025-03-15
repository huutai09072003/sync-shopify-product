require 'rails_helper'

feature 'Product details page', :js => true do
  before do
    @product = create(:product)
    @shop = @product.shop

    allow_any_instance_of(Product).to receive(:image_url).and_return("#{BASE_URL}/assets/starry-night-framed.jpg")
  end

  def wait_for_embed
    sleep(2)
    # log_console
  end

  # def log_keys
  #   %w(port baseResourceUrl recordStatUrl storeName ShopifyProductUrl ctaText styleUrl backgroundImage)
  # end

  # def log_console
  #   puts "====="
  #   log_keys.each { |key| puts "#{key}: #{page.driver.browser.local_storage.fetch(key)}" }
  #   puts "====="
  # end

  scenario 'shopper should see video walkthrough modal' do
    visit test_store_product_path(@product.title)
    wait_for_embed

    expect(page).to have_text 'Live Preview'
  end

  scenario 'admin should be able to customize CTA text' do
    @shop.update(cta_text: 'PREVIEW THIS')

    visit test_store_product_path(@product.title)
    wait_for_embed

    expect(page).to_not have_text 'Live Preview'
    expect(page).to have_text 'PREVIEW THIS'
  end

  scenario 'shopper should create stats' do
    visit test_store_product_path(@product.title)
    wait_for_embed

    expect {
      find('#picture-it-call-to-action').click
      sleep(2)
    }.to change {
      Event.count
    }.by 1
  end
end
