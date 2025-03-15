module PictureItShopifyApi
  class ScriptTag < Base
    class << self
      # example usage:
      # find script tag with id
      ## without fields: PictureItShopifyApi::ScriptTag.find(214272475170)
      ## with fields: PictureItShopifyApi::ScriptTag.find(214272475170, fields: ["id", "src"])
      # find script tag with query
      ## without fields: PictureItShopifyApi::ScriptTag.find_by({ id: 214272475170 })
      ## with fields: PictureItShopifyApi::ScriptTag.find_by({ id: 214272475170 }, fields: ["id", "src"])
      # list all script tags
      ## without fields: PictureItShopifyApi::ScriptTag.all
      ## with fields: PictureItShopifyApi::ScriptTag.all(fields: ["id", "src"], pagination: { next_page_info: "", prev_page_info: "", limit: 2 })
      ## with fields and filter: PictureItShopifyApi::ScriptTag.all(fields: ["id", "src"], filter: {src: "https://app.pictureit.co/load.js"}, pagination: { next_page_info: "", prev_page_info: "", limit: 2 })
      def default_fields
        [
          "id",
          "cache",
          "created_at",
          "display_scope",
          "src",
          "updated_at",
        ]
      end
    end

    private

    def editable_fields
      [
        "cache",
        "display_scope",
        "src"
      ]
    end
  end
end
