module Trailblazer
  class Finder
    module Adapters
      module ActiveRecord
        # ActiveRecord - Predicate Adapter
        module Predicates
          def not_eq(attribute, value, entity_type)
            entity_type.where.not(attribute => value)
          end

          def eq(attribute, value, entity_type)
            entity_type.where(attribute => value)
          end

          def blank(attribute, _value, entity_type)
            entity_type.where(attribute.to_sym => [nil, ''])
          end

          def not_blank(attribute, _value, entity_type)
            entity_type.where.not(attribute.to_sym => [nil, ''])
          end

          def gt(attribute, value, entity_type)
            entity_type.where(["#{attribute} > ?", value.to_f])
          end

          def gte(attribute, value, entity_type)
            entity_type.where(["#{attribute} >= ?", value.to_f])
          end

          def lt(attribute, value, entity_type)
            entity_type.where(["#{attribute} < ?", value.to_f])
          end

          def lte(attribute, value, entity_type)
            entity_type.where(["#{attribute} <= ?", value.to_f])
          end
        end
      end
    end
  end
end
