class ShopChannel < ApplicationCable::Channel
  def subscribed
    stream_from "shop_channel_#{params[:id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
