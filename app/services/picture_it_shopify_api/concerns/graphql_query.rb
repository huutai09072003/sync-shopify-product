module PictureItShopifyApi
  module Concerns
    module GraphqlQuery
      extend ActiveSupport::Concern

      included do
        class << self
          def build_filter_query_string(filter)
            filter_query = filter.map do |k, v|
              case v
              when String
                "#{k}:#{v}"
              when Array
                v.map { |value| "#{k}:#{value}" }.join(" OR ")
              end
            end.join(" ")
            filter_query = "query: \"#{filter_query}\"" if filter_query.present?
            filter_query
          end

          def build_pagination_query_string(next_page_info:, prev_page_info:, limit:)
            if next_page_info.present?
              "first: #{limit}, after: \"#{next_page_info}\""
            elsif prev_page_info.present?
              "last: #{limit}, before: \"#{prev_page_info}\""
            else
              "first: #{limit}"
            end
          end

          def build_fields_for_query_with_navigation_fields(
            fields,
            class_name:,
            filter: {},
            primary_query_key:,
            limit:,
            next_page_info: nil,
            prev_page_info: nil
          )

            queries = [
              build_pagination_query_string(next_page_info: next_page_info, prev_page_info: prev_page_info, limit: limit),
              build_filter_query_string(filter)
            ].reject(&:empty?)

            {
              "#{class_name.to_s.demodulize.camelize(:lower).pluralize}(#{queries.join(", ")})" => [
                {"edges" => [{"#{primary_query_key}" => build_fields_for_query(fields)}, "cursor"]},
                {"pageInfo" => ["hasNextPage, hasPreviousPage"]},
              ]
            }
          end

          def build_fields_for_query_with_id(id, query:, primary_query_key:, class_name:)
            {
              "#{primary_query_key}(id: \"gid://shopify/#{class_name}/#{id}\")" => [
                "id",
                {"... on #{class_name}" => query}
              ]
            }
          end

          def build_fields_for_query(obj)
            case obj
            when Hash
              obj.each_with_object({}) do |(k, v), result|
                new_key = k.to_s.camelize(:lower)

                association = get_association_for(k)

                if association && association[:relation_type] == :has_many
                  v = v.deep_symbolize_keys
                  pagination = v[:pagination] || {}
                  current_fields = association[:relation_class].build_fields_for_query_with_navigation_fields(
                    v[:fields],
                    class_name: k,
                    filter: v[:filter] || {},
                    primary_query_key: "node",
                    limit: pagination[:limit] || 100,
                    next_page_info: pagination[:next_page_info],
                    prev_page_info: pagination[:prev_page_info]
                  )
                  result.merge!(current_fields)
                else
                  result[new_key] = build_fields_for_query(v)
                end
              end
            when Array
              obj.map { |o| build_fields_for_query(o) }
            else
              obj.to_s.camelize(:lower)
            end
          end

          def build_graphql_query_string(field, space = 0)
            if field.is_a?(Hash)
              field.map do |field_name, field_value|
                raise "value of #{field_name} must be an array" unless field_value.is_a?(Array)

                query_string = <<~QUERY
                #{" " * space}#{field_name} {
                #{field_value.map { |f| build_graphql_query_string(f, space + 2) }.join("\n")}
                #{" " * space}}
                QUERY
                query_string.chomp
              end.join("\n")
            else
              "#{" " * space}#{field}"
            end
          end
        end
      end
    end
  end
end
