module PictureItShopifyApi
  class Image < Base
    class << self
      def default_fields
        [
          "id",
          "src"
        ]
      end
    end
  end
end
