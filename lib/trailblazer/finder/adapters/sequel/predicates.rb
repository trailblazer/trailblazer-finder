# frozen_string_literal: true

module Trailblazer
  class Finder
    module Adapters
      # ActiveRecord Adapter
      module Sequel
        # ActiveRecord Predicates Adapter
        module Predicates
          module_function

          def set_eq_handler
            lambda do |entity, attribute, value|
              return if Utils::String.blank?(value.to_s)

              entity.where { ::Sequel[attribute.to_sym] =~ value }
            end
          end

          def set_not_eq_handler
            lambda do |entity, attribute, value|
              return if Utils::String.blank?(value.to_s)

              entity.where { ::Sequel[attribute.to_sym] !~ value }
            end
          end

          def set_blank_handler
            lambda do |entity, attribute, _value|
              entity.where { ::Sequel.|({::Sequel[attribute.to_sym] => nil}, {::Sequel[attribute.to_sym] => ""}) }
            end
          end

          def set_not_blank_handler
            lambda do |entity, attribute, _value|
              entity.exclude(::Sequel[attribute.to_sym] => nil, ::Sequel[attribute.to_sym] => "")
              # entity.exclude(attribute.to_sym => nil).exclude(attribute.to_sym => "")
            end
          end

          def set_gt_handler
            lambda do |entity, attribute, value|
              entity.where { ::Sequel[attribute.to_sym] > value.to_f }
            end
          end

          def set_gte_handler
            lambda do |entity, attribute, value|
              entity.where { ::Sequel[attribute.to_sym] >= value.to_f }
            end
          end

          def set_lt_handler
            lambda do |entity, attribute, value|
              entity.where { ::Sequel[attribute.to_sym] < value.to_f }
            end
          end

          def set_lte_handler
            lambda do |entity, attribute, value|
              entity.where { ::Sequel[attribute.to_sym] <= value.to_f }
            end
          end

          def set_cont_handler
            lambda do |entity, attribute, value|
              entity.where(::Sequel.like(attribute.to_sym, "%#{value}%"))
            end
          end

          def set_not_cont_handler
            lambda do |entity, attribute, value|
              entity.where(~::Sequel.like(attribute.to_sym, "%#{value}%"))
            end
          end

          def set_sw_handler
            lambda do |entity, attribute, value|
              entity.where(::Sequel.like(attribute.to_sym, "#{value}%"))
            end
          end

          def set_not_sw_handler
            lambda do |entity, attribute, value|
              entity.where(~::Sequel.like(attribute.to_sym, "#{value}%"))
            end
          end

          def set_ew_handler
            lambda do |entity, attribute, value|
              entity.where(::Sequel.like(attribute.to_sym, "%#{value}"))
            end
          end

          def set_not_ew_handler
            lambda do |entity, attribute, value|
              entity.where(~::Sequel.like(attribute.to_sym, "%#{value}"))
            end
          end
        end
      end
    end
  end
end
