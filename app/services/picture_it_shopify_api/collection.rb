module PictureItShopifyApi
  class Collection < Base
    has_many :products, class_name: "PictureItShopifyApi::Product", limit: 250

    class << self
      # example usage:
      # find collection with id
      ## without fields: PictureItShopifyApi::Collection.find(477710778402)
      ## with fields: PictureItShopifyApi::Collection.find(477710778402, fields: ["id", "title", products: { fields: ["id"], pagination: { limit: 10 } }])
      # find collection with query
      ## without fields: PictureItShopifyApi::Collection.find_by({ id: 477710778402 })
      ## with fields: PictureItShopifyApi::Collection.find_by({ id: 477710778402 }, fields: ["id", "title", products: { fields: ["id"], pagination: { limit: 10 } }])
      # list all collections
      ## without fields: PictureItShopifyApi::Collection.all
      ## with fields: PictureItShopifyApi::Collection.all(fields: ["id", "title", products: { fields: ["id"], pagination: { next_page_info: "", prev_page_info: "", limit: 10 } }], pagination: { next_page_info: "", prev_page_info: "", limit: 2 })
      ## with fields and filter: PictureItShopifyApi::Collection.all(fields: ["id", "title", products: { fields: ["id"], pagination: { next_page_info: "", prev_page_info: "", limit: 10 } }], filter: {title: "collection test 1"}, pagination: { next_page_info: "", prev_page_info: "", limit: 2 })
      def default_fields
        [
          "id",
          "title",
          {
            products: get_default_fields_for(:products),
          }
        ]
      end
    end
  end
end
