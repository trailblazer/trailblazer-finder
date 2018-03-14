module Trailblazer
  class Finder
    module Adapters
      module Sequel
        # Sequel - Predicates Adapter
        module Predicates

          def not_eq(attribute, value, entity_type)
            entity_type.exclude(attribute.to_sym => value.to_s)
          end

          def eq(attribute, value, entity_type)
            entity_type.where(attribute.to_sym => value.to_s)
          end

          def blank(attribute, value, entity_type)
            entity_type.where(attribute.to_sym => nil).or(attribute.to_sym => "")
          end

          def not_blank(attribute, value, entity_type)
            entity_type.exclude(attribute.to_sym => nil).exclude(attribute.to_sym => "")
          end

          def gt(attribute, value, entity_type)
            entity_type.where{::Sequel[attribute.to_sym] > value.to_f}
          end

          def gte(attribute, value, entity_type)
            entity_type.where{::Sequel[attribute.to_sym] >= value.to_f}
          end

          def lt(attribute, value, entity_type)
            entity_type.where{::Sequel[attribute.to_sym] < value.to_f}
          end

          def lte(attribute, value, entity_type)
            entity_type.where{::Sequel[attribute.to_sym] <= value.to_f}
          end
        end
      end
    end
  end
end
