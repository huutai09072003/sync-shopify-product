module PictureItShopifyApi
  class Metafield < Base
    class << self
      def default_fields
        [
          "id",
          "key",
          "value"
        ]
      end
    end
  end
end
