# frozen_string_literal: true

module Trailblazer
  class Finder
    module Adapters
      # ActiveRecord Adapter
      module ActiveRecord
        # ActiveRecord Predicates Adapter
        module Predicates
          module_function

          def set_eq_handler
            ->(entity, attribute, value) do
              return if Utils::String.blank?(value.to_s)

              entity.where(attribute => value)
            end
          end

          def set_not_eq_handler
            ->(entity, attribute, value) do
              return if Utils::String.blank?(value.to_s)

              entity.where.not(attribute => value)
            end
          end

          def set_blank_handler
            ->(entity, attribute, _value) do
              entity.where(attribute.to_sym => [nil, ""])
            end
          end

          def set_not_blank_handler
            ->(entity, attribute, _value) do
              entity.where.not(attribute.to_sym => [nil, ""])
            end
          end

          def set_gt_handler
            ->(entity, attribute, value) do
              entity.where("#{attribute} > ?", value.to_f)
            end
          end

          def set_gte_handler
            ->(entity, attribute, value) do
              entity.where("#{attribute} >= ?", value.to_f)
            end
          end

          def set_lt_handler
            ->(entity, attribute, value) do
              entity.where("#{attribute} < ?", value.to_f)
            end
          end

          def set_lte_handler
            ->(entity, attribute, value) do
              entity.where("#{attribute} <= ?", value.to_f)
            end
          end

          def set_cont_handler
            ->(entity, attribute, value) do
              entity.where("#{attribute} LIKE ?", "%#{value}%")
            end
          end

          def set_not_cont_handler
            ->(entity, attribute, value) do
              entity.where("#{attribute} NOT LIKE ?", "%#{value}%")
            end
          end

          def set_sw_handler
            ->(entity, attribute, value) do
              entity.where("#{attribute} LIKE ?", "#{value}%")
            end
          end

          def set_not_sw_handler
            ->(entity, attribute, value) do
              entity.where("#{attribute} NOT LIKE ?", "#{value}%")
            end
          end

          def set_ew_handler
            ->(entity, attribute, value) do
              entity.where("#{attribute} LIKE ?", "%#{value}")
            end
          end

          def set_not_ew_handler
            ->(entity, attribute, value) do
              entity.where("#{attribute} NOT LIKE ?", "%#{value}")
            end
          end
        end
      end
    end
  end
end
