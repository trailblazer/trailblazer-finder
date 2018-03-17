module Trailblazer
  class Finder
    module Adapters
      module DataMapper
        # ActiveRecord - Predicate Adapter
        module Predicates
          def not_eq(attribute, value, entity_type)
            entity_type.all(attribute.to_sym.not => value)
          end

          def eq(attribute, value, entity_type)
            entity_type.all(attribute.to_sym => value)
          end

          def blank(attribute, _value, entity_type)
            entity_type.all(conditions: ["#{attribute} IS NULL OR #{attribute} = ?", ''])
          end

          def not_blank(attribute, _value, entity_type)
            entity_type.all(conditions: ["#{attribute} IS NOT NULL AND #{attribute} != ?", ''])
          end

          def gt(attribute, value, entity_type)
            entity_type.all(attribute.to_sym.gt => value)
          end

          def gte(attribute, value, entity_type)
            entity_type.all(attribute.to_sym.gte => value)
          end

          def lt(attribute, value, entity_type)
            entity_type.all(attribute.to_sym.lt => value)
          end

          def lte(attribute, value, entity_type)
            entity_type.all(attribute.to_sym.lte => value)
          end
        end
      end
    end
  end
end
