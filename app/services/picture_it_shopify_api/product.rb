module PictureItShopifyApi
  class Product < Base
    has_many :variants, class_name: "PictureItShopifyApi::ProductVariant", limit: 100
    has_many :images, class_name: "PictureItShopifyApi::Image"
    has_many :metafields, class_name: "PictureItShopifyApi::Metafield", limit: 100

    class << self
      # example usage:
      # find product with id
      ## without fields: PictureItShopifyApi::Product.find(7817796780066)
      ## with fields: PictureItShopifyApi::Product.find(7817796780066, fields: ["id", "title", variants: { fields: ["id"], pagination: { limit: 10 } }, images: { fields: ["url"],  pagination: { limit: 5 } }])
      # find product with query
      ## without fields: PictureItShopifyApi::Product.find_by({ id: 7817796780066 })
      ## with fields: PictureItShopifyApi::Product.find_by({ id: 7817796780066 }, fields: ["id", "title", variants: { fields: ["id"], pagination: { limit: 10 } }, images: { fields: ["url"],  pagination: { limit: 5 } }])
      # list all products
      ## without fields: PictureItShopifyApi::Product.all
      ## with fields: PictureItShopifyApi::Product.all(fields: ["id", "title", variants: { fields: ["id"], pagination: { next_page_info: "", prev_page_info: "", limit: 10 } }, images: { fields: ["url"], pagination: { next_page_info: "", prev_page_info: "", limit: 5 } }], pagination: { next_page_info: "", prev_page_info: "", limit: 2 })
      ## with fields and filter: PictureItShopifyApi::Product.all(fields: ["id", "title", "status", variants: { fields: ["id"], pagination: { next_page_info: "", prev_page_info: "", limit: 10 } }, images: { fields: ["url"], pagination: { next_page_info: "", prev_page_info: "", limit: 5 } }], filter: {status: "draft", title: "Landscape picture 101"}, pagination: { next_page_info: "", prev_page_info: "", limit: 2 })
      def default_fields
        [
          "id",
          "title",
          "created_at",
          "status",
          "body_html",
          "vendor",
          "product_type",
          "handle",
          "tags",
          "template_suffix",
          {
            variants: get_default_fields_for(:variants),
            images: get_default_fields_for(:images),
            metafields: get_default_fields_for(:metafields)
          }
        ]
      end

    end

    def handle_original_state(data)
      current_data = data[primary_query_key]

      current_data['image'] = current_data.transform_keys(&:underscore).stringify_keys.dig("images", "edges")&.first&.dig("node") || {}
      if current_data.key?("tags")
        current_data['original_tags'] = current_data['tags']
        current_data['tags'] = current_data['tags'].join(", ")
      end

      super(data)
    end
  end
end
