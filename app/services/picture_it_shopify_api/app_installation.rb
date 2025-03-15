module PictureItShopifyApi
  class AppInstallation < Base
    class << self
      def current(session: nil, fields: nil)
        instance = self.new(session: session, fields: fields)
        instance.fetch
        instance
      end

      def default_fields
        [
          "id",
          access_scopes: [
            "handle",
          ],
        ]
      end
    end

    def reload
      fetch

      self
    end

    private

    def primary_query_key
      "currentAppInstallation"
    end

    def build_graphql_query(id: nil)
      query = klass.build_fields_for_query({
        primary_query_key => fields || default_fields
      })

      klass.build_graphql_query_string(query: [query])
    end
  end
end
