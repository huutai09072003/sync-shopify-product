module PictureItShopifyApi
  class AppSubscription < Base
    class << self
      def current(session: nil, fields: nil)
        instance = self.new(session: session, fields: fields)
        instance.fetch_current
      end

      def default_fields
        [
          "id",
          "name",
          "created_at",
          "current_period_end",
          "return_url",
          "status",
          "test",
          "trial_days",
          {
            line_items: [
              "id",
              {
                plan: [
                  pricing_details: [
                    {
                      "...on AppRecurringPricing" => [
                        "interval",
                        {
                          price: [
                            "amount",
                            "currency_code"
                          ]
                        }
                      ]
                    }
                  ]
                ]
              }
            ]
          }
        ]
      end
    end

    def fetch_current
      app_installation = PictureItShopifyApi::AppInstallation.current(
        session: session,
        fields: [
          "id",
          {
            active_subscriptions: fields
          }
        ]
      )

      return nil if app_installation.active_subscriptions.empty?

      handle_original_state("node" => app_installation.active_subscriptions.first)
      self
    end

    def save(fields: nil)
      reset_errors
      @fields = (fields || @fields).delete_if { |field| field === "price" }
      current_id = original_state["original_id"]
      create_or_update_key = "appSubscription#{current_id.present? ? 'Update' : 'Create'}"
      mutation_string = build_graphql_mutation(id: current_id, create_or_update_key: create_or_update_key)
      # puts mutation_string
      response = client.query(
        query: mutation_string,
        variables: (
          {
            id: current_id,
          }.merge(input_values)
        )
      )
      handle_mutation_response(response, create_or_update_key: create_or_update_key)
      reset_updating_state if errors.empty?
      errors.empty? ? true : false
    end

    private

    def handle_mutation_response(response, create_or_update_key:)
      if response.body.key?("data")
        if response.body["data"].key?(create_or_update_key) && response.body["data"][create_or_update_key].nil?
          raise_record_not_found("An error occurred while saving AppSubscription: Record not found")
        end
        node = response.body["data"][create_or_update_key][class_name.camelize(:lower)]

        if response.body["data"][create_or_update_key].key?("confirmationUrl")
          node["confirmationUrl"] = response.body["data"][create_or_update_key]["confirmationUrl"]
        end

        handle_original_state("node" => node)
      else
        response.body["errors"].each { |error| @errors << error["message"] }
      end
    end

    def build_graphql_mutation(id: nil, create_or_update_key:)
      mutation = klass.build_fields_for_query(fields)

      mutation = {
        "mutation #{create_or_update_key}($name: String!, $lineItems: [AppSubscriptionLineItemInput!]!, $trialDays: Int, $test: Boolean, $returnUrl: URL!#{id ? ', $id: ID!' : ''})" => [
          "#{create_or_update_key}(name: $name, lineItems: $lineItems, trialDays: $trialDays, test: $test, returnUrl: $returnUrl#{id ? ', id: $id' : ''})" => [
            "confirmationUrl",
            "#{class_name.camelize(:lower)}" => mutation,
            "userErrors" => ["field", "message"]
          ]
        ]
      }

      klass.build_graphql_query_string(mutation)
    end

    def input_values
      {
        "name": @updating_state["name"],
        "lineItems": [
          {
            "plan"=>{"appRecurringPricingDetails"=>{"price"=>{"amount"=>@updating_state["price"], "currencyCode"=>"USD"}, "interval"=>"EVERY_30_DAYS"}}
          }
        ],
        "trialDays": @updating_state["trial_days"],
        "test": @updating_state["test"],
        "returnUrl": @updating_state["return_url"],
      }
    end

    def editable_fields
      [
        "name",
        "price",
        "trial_days",
        "test",
        "return_url",
      ]
    end

    def handle_original_state(data)
      data["node"]["price"] = data.dig("node", "lineItems")&.first&.dig("plan", "pricingDetails", "price", "amount")

      super(data)
    end
  end
end
