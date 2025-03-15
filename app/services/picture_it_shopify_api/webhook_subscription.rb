module PictureItShopifyApi
  class WebhookSubscription < Base
    class << self
      # example usage:
      # find webhook subscription with id
      ## without fields: PictureItShopifyApi::WebhookSubscription.find(1561262850082)
      ## with fields: PictureItShopifyApi::WebhookSubscription.find(1561262850082, fields: ["id", "callback_url"])
      # find webhook subscription with query
      ## without fields: PictureItShopifyApi::WebhookSubscription.find_by({ id: 1561262850082 })
      ## with fields: PictureItShopifyApi::WebhookSubscription.find_by({ id: 1561262850082 }, fields: ["id", "callback_url"])
      # list all webhook subscriptions
      ## without fields: PictureItShopifyApi::WebhookSubscription.all
      ## with fields: PictureItShopifyApi::WebhookSubscription.all(fields: ["id", "callback_url"], pagination: { next_page_info: "", prev_page_info: "", limit: 2 })
      ## with fields and filter: PictureItShopifyApi::WebhookSubscription.all(fields: ["id", "callback_url"], filter: {callback_url: "https://picture-it.ngrok.io//webhooks/products_create"}, pagination: { next_page_info: "", prev_page_info: "", limit: 2 })
      def default_fields
        [
          "id",
          "created_at",
          "endpoint",
          "filter",
          "format",
          "include_fields",
          "legacy_resource_id",
          "metafield_namespaces",
          "topic",
          "updated_at",
          "callback_url",
        ]
      end
    end

    def save
      reset_errors
      current_id = original_state["original_id"]
      create_or_update_key = "#{class_name.camelize(:lower)}#{current_id.present? ? 'Update' : 'Create'}"
      if current_id.present?
        super()
      else
        mutation_string = build_graphql_mutation(id: current_id, create_or_update_key: create_or_update_key)
        # puts mutation_string
        response = client.query(
          query: mutation_string,
          variables: (
            {
              topic: @updating_state["topic"],
            }.merge(input_values)
          )
        )
        handle_mutation_response(response, create_or_update_key: create_or_update_key)
        reset_updating_state if errors.empty?
        errors.empty? ? true : false
      end
    end

    private

    def build_graphql_mutation(id: nil, create_or_update_key:)
      if id.present?
        super(id: id, create_or_update_key: create_or_update_key)
      else
        mutation = klass.build_fields_for_query(fields)

        mutation = {
          "mutation #{create_or_update_key}($topic: WebhookSubscriptionTopic!, $webhookSubscription: WebhookSubscriptionInput!)" => [
            "#{create_or_update_key}(topic: $topic, #{mutation_input_key}: $#{mutation_input_key})" => [
              "#{class_name.camelize(:lower)}" => mutation,
              "userErrors" => ["field", "message"]
            ]
          ]
        }

        klass.build_graphql_query_string(mutation)
      end
    end

    def handle_mutation_response(response, create_or_update_key:)
      if original_state["original_id"].present?
        super(response, create_or_update_key: create_or_update_key)
      else
        if response.body.key?("data")
          mutation_data = response.body["data"][create_or_update_key]

          if mutation_data.nil?
            raise_record_not_found("An error occurred while saving data: Record not found")
          end

          if mutation_data["userErrors"]&.any?
            mutation_data["userErrors"].each do |error|
              @errors << error["message"]
            end

            return
          end

          handle_original_state("node" => mutation_data[class_name.camelize(:lower)])
        else
          response.body["errors"].each { |error| @errors << error["message"] }
        end
      end
    end

    def input_values
      {
        "#{class_name.camelize(:lower)}": {
          "callbackUrl": @updating_state["callback_url"],
          "format": @updating_state["format"],
          "includeFields": @updating_state["include_fields"],
        }
      }
    end

    def editable_fields
      [
        "include_fields",
        "callback_url",
        "format",
        "topic",
      ]
    end

    def mutation_input_key
      "webhookSubscription"
    end
  end
end
