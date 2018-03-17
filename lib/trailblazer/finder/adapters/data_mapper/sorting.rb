module Trailblazer
  class Finder
    module Adapters
      module DataMapper
        # Sequel - Sorting Adapter
        module Sorting
          def self.included(base)
            base.extend Features::Sorting::ClassMethods
          end

          private

          # def sort_it(entity_type, sort_attribute, sort_direction)
          #   case sort_direction
          #   when 'asc', 'ascending'
          #     entity_type.all(order: [sort_attribute.to_sym.asc])
          #   when 'desc', 'descending'
          #     entity_type.all(order: [sort_attribute.to_sym.desc])
          #   end
          # end

          def sort_orders(sort_attr, sort_dir)
            case sort_dir
            when 'asc', 'ascending'
              sort_attr.to_sym.asc
            when 'desc', 'descending'
              sort_attr.to_sym.desc
            end
          end

          def sort_it(entity_type, sort_attributes)
            entity_type.all(order: sort_attributes.flatten)
          end
        end
      end
    end
  end
end
