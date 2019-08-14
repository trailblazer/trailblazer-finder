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
            lambda do |entity, attribute, value|
              return if Utils::String.blank?(value.to_s) || Utils::String.blank?(attribute.to_s)

              Utils::Hash.deep_locate ->(k, v, _) { k == attribute.to_sym && v.to_s == value.to_s && !v.nil? }, entity
            end
          end

          def set_not_eq_handler
            lambda do |entity, attribute, value|
              return if Utils::String.blank?(value.to_s)

              Utils::Hash.deep_locate ->(k, v, _) { k == attribute.to_sym && v.to_s != value.to_s && !v.nil? }, entity
            end
          end

          def set_blank_handler
            lambda do |entity, attribute, _value|
              Utils::Hash.deep_locate ->(k, v, _) { k == attribute.to_sym && Utils::String.blank?(v.to_s) }, entity
            end
          end

          def set_not_blank_handler
            lambda do |entity, attribute, _value|
              Utils::Hash.deep_locate ->(k, v, _) { k == attribute.to_sym && !Utils::String.blank?(v.to_s) }, entity
            end
          end

          def set_gt_handler
            lambda do |entity, attribute, value|
              Utils::Hash.deep_locate ->(k, v, _) { k == attribute.to_sym && v.to_f > value.to_f }, entity
            end
          end

          def set_gte_handler
            lambda do |entity, attribute, value|
              Utils::Hash.deep_locate ->(k, v, _) { k == attribute.to_sym && v.to_f >= value.to_f }, entity
            end
          end

          def set_lt_handler
            lambda do |entity, attribute, value|
              Utils::Hash.deep_locate ->(k, v, _) { k == attribute.to_sym && v.to_f < value.to_f }, entity
            end
          end

          def set_lte_handler
            lambda do |entity, attribute, value|
              Utils::Hash.deep_locate ->(k, v, _) { k == attribute.to_sym && v.to_i <= value.to_f }, entity
            end
          end

          def set_cont_handler
            lambda do |entity, attribute, value|
              return if Utils::String.blank?(value.to_s) || Utils::String.blank?(attribute.to_s)

              Utils::Hash.deep_locate ->(k, v, _) { k == attribute.to_sym && v.to_s.include?(value.to_s) && !v.nil? }, entity
            end
          end

          def set_not_cont_handler
            lambda do |entity, attribute, value|
              return if Utils::String.blank?(value.to_s) || Utils::String.blank?(attribute.to_s)

              Utils::Hash.deep_locate ->(k, v, _) { k == attribute.to_sym && !v.to_s.include?(value.to_s) && !v.nil? }, entity
            end
          end

          def set_sw_handler
            lambda do |entity, attribute, value|
              return if Utils::String.blank?(value.to_s) || Utils::String.blank?(attribute.to_s)

              Utils::Hash.deep_locate ->(k, v, _) { k == attribute.to_sym && v.to_s.start_with?(value.to_s) && !v.nil? }, entity
            end
          end

          def set_not_sw_handler
            lambda do |entity, attribute, value|
              return if Utils::String.blank?(value.to_s) || Utils::String.blank?(attribute.to_s)

              Utils::Hash.deep_locate ->(k, v, _) { k == attribute.to_sym && !v.to_s.start_with?(value.to_s) && !v.nil? }, entity
            end
          end

          def set_ew_handler
            lambda do |entity, attribute, value|
              return if Utils::String.blank?(value.to_s) || Utils::String.blank?(attribute.to_s)

              Utils::Hash.deep_locate ->(k, v, _) { k == attribute.to_sym && v.to_s.end_with?(value.to_s) && !v.nil? }, entity
            end
          end

          def set_not_ew_handler
            lambda do |entity, attribute, value|
              return if Utils::String.blank?(value.to_s) || Utils::String.blank?(attribute.to_s)

              Utils::Hash.deep_locate ->(k, v, _) { k == attribute.to_sym && !v.to_s.end_with?(value.to_s) && !v.nil? }, entity
            end
          end
        end
      end
    end
  end
end
