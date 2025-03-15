module PictureItShopifyApi
  class Relation < Base
    attr_reader :limit, :next_page_info, :prev_page_info

    class << self
      def handle_collection_data(data_collection, klass:, session:)
        data_collection.map do |data|
          obj = klass.new(session: session)
          obj.send(:handle_original_state, data)
          obj
        end
      end
    end

    def initialize(session: ShopifyAPI::Context.active_session, fields:, filter: {}, limit:, next_page_info: nil, prev_page_info: nil, klass:)
      @klass = klass
      @limit = limit
      @next_page_info = next_page_info
      @prev_page_info = prev_page_info
      @session = session
      @fields = fields
      @filter = filter

      check_valid_arguments
    end

    def reload
      fetch

      self
    end

    private

    def handle_fetch_response(response)
      handle_extension_response(response)

      if response.body["data"].present?
        data = response.body["data"][klass.to_s.demodulize.camelize(:lower).pluralize]
        data_collection = data["edges"]
        pagination_data = (data["pageInfo"] || {}).deep_transform_keys(&:underscore).deep_stringify_keys

        @original_state = {
          data: self.class.handle_collection_data(data_collection, klass: klass, session: session),
          pagination: handle_pagination_data(pagination_data, data_collection)
        }

        original_state.each do |key, value|
          define_instance_method_with(key, value)
        end
      else
        message = response.body["errors"].map { |error| error["message"] }.join(", ")

        raise("An error occurred while fetching list data: #{message}")
      end
    end

    def handle_pagination_data(pagination_data, data_collection)
      pagination_data["has_next_page"] ||= false
      pagination_data["has_previous_page"] ||= false
      pagination_data["next_page_info"] ||= pagination_data["has_next_page"] ? data_collection.last["cursor"] : nil
      pagination_data["prev_page_info"] ||= pagination_data["has_previous_page"] ? data_collection.first["cursor"] : nil

      pagination_data
    end

    def check_valid_arguments
      if next_page_info.present? && prev_page_info.present?
        raise ArgumentError, "next_page_info and prev_page_info cannot be present at the same time"
      end

      super
    end

    def default_fields
      raise ArgumentError, "default_fields not used in this class"
    end
  end
end
