module PictureItShopifyApi
  module Concerns
    module Association
      extend ActiveSupport::Concern

      included do
        class << self
          def relation_attributes
            @relation_attributes ||= []
          end

          def get_default_fields_for(relation_name)
            association = get_association_for(relation_name)

            if association[:relation_type] == :has_many
              {
                fields: association[:relation_class].default_fields,
                filter: {},
                pagination: {
                  next_page_info: nil,
                  prev_page_info: nil,
                  limit: association[:limit]
                }
              }
            else
              association[:relation_class].default_fields
            end
          end

          def get_association_for(relation_name)
            relation_name = relation_name.to_s
            relation_attributes.find { |relation| relation[:relation_name].to_s == relation_name }
          end

          private

          def push_to_relation_attributes(value)
            @relation_attributes ||= []

            @relation_attributes.push(value)
          end

          def has_many(relation_name, class_name:, limit: 100)
            push_to_relation_attributes({
              relation_type: :has_many,
              relation_name: relation_name,
              relation_class: class_name.constantize,
              limit: limit
            })
          end

          def has_one(relation_name, class_name:)
            push_to_relation_attributes({
              relation_type: :has_one,
              relation_name: relation_name,
              relation_class: class_name.constantize
            })
          end

          def belongs_to(relation_name, class_name:)
            push_to_relation_attributes({
              relation_type: :belongs_to,
              relation_name: relation_name,
              relation_class: class_name.constantize
            })
          end
        end
      end
    end
  end
end
