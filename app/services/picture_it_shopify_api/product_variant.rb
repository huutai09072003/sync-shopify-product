module PictureItShopifyApi
  class ProductVariant < Base
    class << self
      def default_fields
        [
          "id",
          "title",
          {
            image: [
              "id"
            ]
          }
        ]
      end
    end

    def handle_original_state(data)
      if data[primary_query_key]['image']
        image = data[primary_query_key]['image'].deep_transform_keys(&:underscore).deep_stringify_keys
        if image['id']
          image['original_id'] = image['id']
          image['id'] = image['id'].split('/').last
        end

        data[primary_query_key]['image'] = image
      else
        data[primary_query_key]['image'] = {}
      end

      super(data)
    end
  end
end
