# frozen_string_literal: true

module Trailblazer
  class Finder
    module Adapters
      # ActiveRecord Adapter
      module Basic
        # Basic Predicates Adapter
        module Predicates
          module_function

          def set_eq_handler
            ->(entity, attribute, value) do
              return if Utils::String.blank?(value.to_s) || Utils::String.blank?(attribute.to_s)

              Utils::Hash.deep_locate ->(k, v, _) { k == attribute.to_sym && v.to_s == value.to_s && !v.nil? }, entity
            end
          end

          def set_not_eq_handler
            ->(entity, attribute, value) do
              return if Utils::String.blank?(value.to_s)

              Utils::Hash.deep_locate ->(k, v, _) { k == attribute.to_sym && v.to_s != value.to_s && !v.nil? }, entity
            end
          end

          def set_blank_handler
            ->(entity, attribute, _value) do
              Utils::Hash.deep_locate ->(k, v, _) { k == attribute.to_sym && Utils::String.blank?(v.to_s) }, entity
            end
          end

          def set_not_blank_handler
            ->(entity, attribute, _value) do
              Utils::Hash.deep_locate ->(k, v, _) { k == attribute.to_sym && !Utils::String.blank?(v.to_s) }, entity
            end
          end

          def set_gt_handler
            ->(entity, attribute, value) do
              Utils::Hash.deep_locate ->(k, v, _) { k == attribute.to_sym && v.to_f > value.to_f }, entity
            end
          end

          def set_gte_handler
            ->(entity, attribute, value) do
              Utils::Hash.deep_locate ->(k, v, _) { k == attribute.to_sym && v.to_f >= value.to_f }, entity
            end
          end

          def set_lt_handler
            ->(entity, attribute, value) do
              Utils::Hash.deep_locate ->(k, v, _) { k == attribute.to_sym && v.to_f < value.to_f }, entity
            end
          end

          def set_lte_handler
            ->(entity, attribute, value) do
              Utils::Hash.deep_locate ->(k, v, _) { k == attribute.to_sym && v.to_i <= value.to_f }, entity
            end
          end

          def set_cont_handler
            ->(entity, attribute, value) do
              return if Utils::String.blank?(value.to_s) || Utils::String.blank?(attribute.to_s)

              Utils::Hash.deep_locate ->(k, v, _) { k == attribute.to_sym && v.to_s.include?(value.to_s) && !v.nil? }, entity
            end
          end

          def set_not_cont_handler
            ->(entity, attribute, value) do
              return if Utils::String.blank?(value.to_s) || Utils::String.blank?(attribute.to_s)

              Utils::Hash.deep_locate ->(k, v, _) { k == attribute.to_sym && !v.to_s.include?(value.to_s) && !v.nil? }, entity
            end
          end

          def set_sw_handler
            ->(entity, attribute, value) do
              return if Utils::String.blank?(value.to_s) || Utils::String.blank?(attribute.to_s)

              Utils::Hash.deep_locate ->(k, v, _) { k == attribute.to_sym && v.to_s.start_with?(value.to_s) && !v.nil? }, entity
            end
          end

          def set_not_sw_handler
            ->(entity, attribute, value) do
              return if Utils::String.blank?(value.to_s) || Utils::String.blank?(attribute.to_s)

              Utils::Hash.deep_locate ->(k, v, _) { k == attribute.to_sym && !v.to_s.start_with?(value.to_s) && !v.nil? }, entity
            end
          end

          def set_ew_handler
            ->(entity, attribute, value) do
              return if Utils::String.blank?(value.to_s) || Utils::String.blank?(attribute.to_s)

              Utils::Hash.deep_locate ->(k, v, _) { k == attribute.to_sym && v.to_s.end_with?(value.to_s) && !v.nil? }, entity
            end
          end

          def set_not_ew_handler
            ->(entity, attribute, value) do
              return if Utils::String.blank?(value.to_s) || Utils::String.blank?(attribute.to_s)

              Utils::Hash.deep_locate ->(k, v, _) { k == attribute.to_sym && !v.to_s.end_with?(value.to_s) && !v.nil? }, entity
            end
          end
        end
      end
    end
  end
end
