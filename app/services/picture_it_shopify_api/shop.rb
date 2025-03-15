module PictureItShopifyApi
  class Shop < Base
    class << self
      def current(session: nil, fields: nil)
        instance = self.new(session: session, fields: fields)
        instance.fetch
        instance
      end

      def default_fields
        [
          "id",
          "name",
          "email",
          "myshopify_domain",
          {
            plan: [
              "display_name"
            ],
            primary_domain: [
              "id",
              "host",
              "url"
            ]
          }
        ]
      end
    end

    def reload
      fetch

      self
    end

    private

    def primary_query_key
      "shop"
    end

    def build_graphql_query(id: nil)
      query = klass.build_fields_for_query({
        primary_query_key => fields || default_fields
      })

      klass.build_graphql_query_string(query: [query])
    end

    def handle_original_state(data)
      if data[primary_query_key]['plan']
        plan_name = handle_plan_name(data[primary_query_key]['plan']['displayName'])
        data[primary_query_key]['plan_name'] = plan_name
      end

      if data[primary_query_key]['primaryDomain']
        primary_domain = data[primary_query_key]['primaryDomain']['host']
        data[primary_query_key]['domain'] = primary_domain
      end

      super(data)
    end

    def handle_plan_name(display_name)
      plan_mapping = {
        "Basic" => "basic",
        "Development" => "affiliate",
        "Advanced" => "unlimited",
        "Shopify" => "professional",
        "Pause and Build" => "dormant",
        "Developer Preview" => "partner_test",
        "Shopify Plus" => "shopify_plus",
        "NPO Full" => "npo_full",
        "Shopify Plus Partner Sandbox" => "plus_partner_sandbox"
      }

      plan_mapping[display_name] || display_name.parameterize.underscore
    end
  end
end
