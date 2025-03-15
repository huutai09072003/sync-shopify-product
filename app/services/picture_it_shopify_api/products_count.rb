module PictureItShopifyApi
  class ProductsCount < Base
    class << self
      def count(session: nil, filter: {})
        instance = self.new(session: session, filter: filter)
        instance.fetch
        instance.count
      end

      def count_active(session: nil)
        count(session: session, filter: { status: "active*" }) # active* to trigger the limitation of the Shopify API(max 10000)
      end

      def count_draft(session: nil)
        count(session: session, filter: { status: "draft*" }) # draft* to trigger the limitation of the Shopify API(max 10000)
      end

      def default_fields
        [
          "count",
        ]
      end
    end

    private

    def primary_query_key
      "productsCount"
    end

    def build_graphql_query(id: nil)
      filter_query_string = klass.build_filter_query_string(filter)
      query_key = if filter_query_string.present?
        "#{primary_query_key}(#{filter_query_string})"
      else
        primary_query_key
      end


      query = klass.build_fields_for_query({
        query_key => fields || default_fields
      })

      klass.build_graphql_query_string(query: [query])
    end
  end
end
