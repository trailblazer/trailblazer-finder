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
            lambda do |entity, attribute, value|
              return if Utils::String.blank?(value.to_s)

              entity.where(attribute => value)
            end
          end

          def set_not_eq_handler
            lambda do |entity, attribute, value|
              return if Utils::String.blank?(value.to_s)

              entity.where.not(attribute => value)
            end
          end

          def set_blank_handler
            lambda do |entity, attribute, _value|
              entity.where(attribute.to_sym => [nil, ""])
            end
          end

          def set_not_blank_handler
            lambda do |entity, attribute, _value|
              entity.where.not(attribute.to_sym => [nil, ""])
            end
          end

          def set_gt_handler
            lambda do |entity, attribute, value|
              entity.where("#{attribute} > ?", value.to_f)
            end
          end

          def set_gte_handler
            lambda do |entity, attribute, value|
              entity.where("#{attribute} >= ?", value.to_f)
            end
          end

          def set_lt_handler
            lambda do |entity, attribute, value|
              entity.where("#{attribute} < ?", value.to_f)
            end
          end

          def set_lte_handler
            lambda do |entity, attribute, value|
              entity.where("#{attribute} <= ?", value.to_f)
            end
          end

          def set_cont_handler
            lambda do |entity, attribute, value|
              entity.where("#{attribute} LIKE ?", "%#{value}%")
            end
          end

          def set_not_cont_handler
            lambda do |entity, attribute, value|
              entity.where("#{attribute} NOT LIKE ?", "%#{value}%")
            end
          end

          def set_sw_handler
            lambda do |entity, attribute, value|
              entity.where("#{attribute} LIKE ?", "#{value}%")
            end
          end

          def set_not_sw_handler
            lambda do |entity, attribute, value|
              entity.where("#{attribute} NOT LIKE ?", "#{value}%")
            end
          end

          def set_ew_handler
            lambda do |entity, attribute, value|
              entity.where("#{attribute} LIKE ?", "%#{value}")
            end
          end

          def set_not_ew_handler
            lambda do |entity, attribute, value|
              entity.where("#{attribute} NOT LIKE ?", "%#{value}")
            end
          end
        end
      end
    end
  end
end
