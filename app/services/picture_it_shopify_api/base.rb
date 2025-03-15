module PictureItShopifyApi
  class Base
    include PictureItShopifyApi::Concerns::Association
    include PictureItShopifyApi::Concerns::GraphqlQuery

    attr_reader :session, :fields, :original_state, :updating_state, :klass, :filter, :errors

    class << self
      def find(id, session: nil, fields: nil)
        instance = self.new(session: session, fields: fields)
        instance.fetch(id: id)
        instance
      end

      def find_by(filter, session: nil, fields: nil)
        all(session: session, fields: fields, filter: filter, pagination: { limit: 1 }).data.first
      end

      def all(session: nil, fields: nil, filter: {}, pagination: {})
        limit = pagination[:limit] || 100
        next_page_info = pagination[:next_page_info]
        prev_page_info = pagination[:prev_page_info]

        instance = PictureItShopifyApi::Relation.new(
          session: session,
          fields: fields || default_fields,
          filter: filter,
          limit: limit,
          next_page_info: next_page_info,
          prev_page_info: prev_page_info,
          klass: self
        )

        instance.fetch
        instance
      end

      def default_fields
        raise "default_fields must be implemented in subclass"
      end
    end

    def initialize(session: ShopifyAPI::Context.active_session, fields: nil, filter: {})
      @klass = self.class
      @session = session
      @fields = fields || default_fields
      reset_updating_state
      reset_errors
      @original_state = {}
      @filter = filter

      check_valid_arguments
    end

    def attributes
      instance_variables.each_with_object({}) do |var, result|
        var_delete_prefix = var.to_s.delete_prefix("@")
        association = klass.get_association_for(var_delete_prefix)

        if association.present? ||
            var == :@session ||
            var == :@fields ||
            var == :@updating_state ||
            var == :@original_state ||
            var == :@klass ||
            var == :@filter ||
            var == :@errors

          next
        end

        result[var_delete_prefix] = instance_variable_get(var)
      end
    end

    def fetch(id: nil)
      query_string = build_graphql_query(id: id)
      # puts query_string
      response = client.query(query: query_string)

      handle_fetch_response(response)
    end

    def save(fields: nil)
      reset_errors
      @fields = fields || @fields
      current_id = original_state["original_id"]
      create_or_update_key = "#{class_name.camelize(:lower)}#{current_id.present? ? 'Update' : 'Create'}"
      mutation_string = build_graphql_mutation(id: current_id, create_or_update_key: create_or_update_key)
      # puts mutation_string
      response = client.query(query: mutation_string, variables: {
        id: current_id,
        mutation_input_key => mutation_input_values
      })
      handle_mutation_response(response, create_or_update_key: create_or_update_key)
      reset_updating_state if errors.empty?
      errors.empty? ? true : false
    end

    def save!
      save || raise(errors.join(", "))
    end

    def destroy
      reset_errors
      current_id = original_state["original_id"]
      mutation_query_key = "#{class_name.camelize(:lower)}Delete"
      mutation = {
        "mutation #{mutation_query_key}($id: ID!)" => [
          "#{mutation_query_key}(id: $id)" => [
            "userErrors" => ["field", "message"]
          ]
        ]
      }
      response = client.query(query: klass.build_graphql_query_string(mutation), variables: { id: current_id })
      handle_delete_response(response, mutation_query_key: mutation_query_key)
      errors.empty? ? true : false
    end

    def destroy!
      destroy || raise(errors.join(", "))
    end

    def reload
      fetch(id: original_state["id"])
      reset_updating_state

      self
    end

    # extensions: {"cost"=> {
    #   "requested_query_cost"=>255,
    #   "actual_query_cost"=>255,
    #   "throttle_status"=>{"maximum_available"=>2000.0, "currently_available"=>1745, "restore_rate"=>100.0}}
    # }
    def going_to_throttle?
      currently_available_cost = extensions.dig("cost", "throttle_status", "currently_available") # The amount of cost currently available to the client.

      if currently_available_cost.present?
        currently_available_cost.to_f < least_query_cost
      else
        false
      end
    end

    def throttle_restore_time # The estimated time in seconds before the client can execute another query.
      restore_rate = extensions.dig("cost", "throttle_status", "restore_rate").to_f

      return 0 if restore_rate.zero? || !going_to_throttle?

      currently_available_cost = extensions.dig("cost", "throttle_status", "currently_available").to_f # The amount of cost currently available to the client.
      cost_needed_to_restore = least_query_cost - currently_available_cost

      cost_needed_to_restore / restore_rate
    end

    def extensions
      @extensions || {}
    end

    private

    def raise_record_not_found(message)
      raise ActiveRecord::RecordNotFound, message
    end

    def least_query_cost
      least_cost = 1000
      buffer = 2.5 # buffer 2.5 times the cost
      requested_query_cost = extensions.dig("cost", "requested_query_cost").to_f # The estimated cost of the query before it is executed.
      actual_query_cost = extensions.dig("cost", "actual_query_cost").to_f # The actual cost of the query after it is executed.
      maximum_available_cost = extensions.dig("cost", "throttle_status", "maximum_available").to_f # The maximum amount of cost that the client can use.

      max_cost = [(requested_query_cost * buffer), (actual_query_cost * buffer), least_cost].max

      if maximum_available_cost.zero?
        max_cost
      else
        [max_cost, maximum_available_cost].min
      end
    end

    def mutation_input_values
      updating_state.deep_transform_keys { |key| key.to_s.camelize(:lower) }
    end

    def mutation_input_key
      "input"
    end

    def inspect
      "#<#{self.class.name} #{attributes.map { |k, v| "#{k}: #{v.inspect}" }.join(", ")}>"
    end

    def method_missing(method_name, *args, &block)
      is_setter = method_name.to_s.end_with?("=")
      method_name_without_equal = method_name.to_s.delete_suffix("=")
      association = klass.get_association_for(method_name_without_equal)

      if is_setter && association.blank?

        if editable_fields.exclude?(method_name_without_equal)
          return super
        end

        handle_method_missing_setter(method_name_without_equal, args.first)
      else
        super
      end
    end

    def reset_updating_state
      @updating_state = {}
    end

    def reset_errors
      @errors = []
    end

    def editable_fields
      default_fields.select { |field| !field.is_a?(Hash) }.map(&:to_s) - ["id"]
    end

    def check_valid_arguments
      if fields.blank?
        raise ArgumentError, "fields cannot be blank"
      end

      unless fields.is_a?(Array)
        raise ArgumentError, "fields must be an array"
      end

      unless filter.is_a?(Hash)
        raise ArgumentError, "filter must be a hash"
      end
    end

    def primary_query_key
      "node"
    end

    def handle_original_state(data)
      current_data = data[primary_query_key].transform_keys(&:underscore).stringify_keys

      if data.key?("cursor")
        define_instance_method_with("cursor", data["cursor"])
      end

      if current_data.key?("id")
        current_data["original_id"] = current_data["id"]
        current_data["id"] = current_data["id"].split("/").last
      end

      current_data.each do |key, value|
        association = klass.get_association_for(key)
        if association.present?
          if association[:relation_type] == :has_many
            value = PictureItShopifyApi::Relation.handle_collection_data(value["edges"], klass: association[:relation_class], session: session)
            new_original_state = value.map(&:original_state)
          else
            value = association[:relation_class].new.send(:handle_original_state, value)
            new_original_state = value.original_state
          end
        end

        @original_state[key] = new_original_state || value
        define_instance_method_with(key, value)
      end
    end

    def handle_fetch_response(response)
      handle_extension_response(response)

      if response.body.key?("data")
        if response.body["data"].key?("node") && response.body["data"]["node"].nil?
          raise_record_not_found("An error occurred while fetching data: Record not found")
        end

        handle_original_state(response.body["data"])
      else
        message = response.body["errors"].map { |error| error["message"] }.join(", ")

        raise("An error occurred while fetching data: #{message}")
      end
    end

    def handle_extension_response(response)
      @extensions = response.body["extensions"].deep_transform_keys(&:underscore).deep_stringify_keys if response.body["extensions"].present?
    end

    def handle_mutation_response(response, create_or_update_key:)
      if response.body.key?("data")
        if response.body["data"].key?(create_or_update_key) && response.body["data"][create_or_update_key].nil?
          raise_record_not_found("An error occurred while saving data: Record not found")
        end

        handle_original_state("node" => response.body["data"][create_or_update_key][class_name.camelize(:lower)])
      else
        response.body["errors"].each { |error| @errors << error["message"] }
      end
    end

    def handle_delete_response(response, mutation_query_key:)
      if response.body.key?("data")
        if response.body["data"][mutation_query_key].key?("userErrors") && response.body["data"][mutation_query_key]["userErrors"].any?
          response.body["data"][mutation_query_key]["userErrors"].each { |error| @errors << error["message"] }
        end
      else
        message = response.body["errors"].map { |error| error["message"] }.join(", ")

        raise("An error occurred while deleting data: #{message}")
      end
    end

    def handle_method_missing_setter(method_name, value)
      if fields.select{|f| !f.is_a?(Hash)}.map{ |field| field.to_s.underscore }.exclude?(method_name.to_s)
        @fields << method_name.to_s
      end

      @updating_state[method_name] = value

      define_instance_method_with(method_name, value)
    end

    def define_instance_method_with(name, value)
      instance_variable_set("@#{name}", value)

      define_singleton_method(name) do
        instance_variable_get("@#{name}")
      end
    end

    def class_name
      klass.name.demodulize
    end

    def default_fields
      klass.default_fields
    end

    def client
      ShopifyAPI::Clients::Graphql::Admin.new(
        session: session,
      )
    end

    def build_graphql_mutation(id: nil, create_or_update_key:)
      mutation = klass.build_fields_for_query(fields)

      mutation = {
        "mutation #{create_or_update_key}($#{mutation_input_key}: #{class_name}Input!#{id ? ', $id: ID!' : ''})" => [
          "#{create_or_update_key}(#{mutation_input_key}: $#{mutation_input_key}#{id ? ', id: $id' : ''})" => [
            "#{class_name.camelize(:lower)}" => mutation,
            "userErrors" => ["field", "message"]
          ]
        ]
      }

      klass.build_graphql_query_string(mutation)
    end

    def build_graphql_query(id: nil)
      query = klass.build_fields_for_query(fields)

      query = if id.present?
        klass.build_fields_for_query_with_id(id, query: query, primary_query_key: primary_query_key, class_name: class_name)
      else
        klass.build_fields_for_query_with_navigation_fields(
          query,
          class_name: klass,
          filter: filter || {},
          primary_query_key: primary_query_key,
          limit: limit,
          next_page_info: next_page_info,
          prev_page_info: prev_page_info
        )
      end

      query = {
        "query" => [query],
      }

      klass.build_graphql_query_string(query)
    end
  end
end
