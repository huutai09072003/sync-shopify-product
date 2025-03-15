class Api::V1::ProductImagesController < Api::V1::BaseController
  before_action :set_product

  def show
    order = params[:order]&.to_unsafe_hash || { created_at: :desc }
    render json: transform_response(product_images: @product.images_urls(order: order))
  end

  def create
    @product.images.attach(params[:image_signed_id])
    render json: transform_response(product_images: @product.images_urls(order: { created_at: :desc }))
  end

  def update
    image_url = params[:image_url]

    if image_url.present? && @shop && @product
      RemoveTheBackgroundOfTheImageForProductJob.perform_later(
        shop_id: @shop.id,
        product_id: @product.id,
        image_url: image_url,
        apply_new_image: params[:apply_new_image].to_b,
        format: 'auto',
        size: 'auto',
        crop: true
      )

      render json: { message: 'The background is being removed from the image' }, status: :ok
    else
      render json: { message: 'Invalid request' }, status: :unprocessable_entity
    end
  end

  def destroy
    image = ActiveStorage::Attachment.find(params[:attachment_id])
    image.purge_later

    head :no_content
  end

  private

  def set_product
    @product = @shop.products.find(params[:id])
  end
end
