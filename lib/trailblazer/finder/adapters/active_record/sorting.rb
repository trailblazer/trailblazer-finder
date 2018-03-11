module Trailblazer
  class Finder
    module Adapters
      module ActiveRecord
        # ActiveRecord - Sorting Adapter
        module Sorting
          def self.included(base)
            base.extend Features::Sorting::ClassMethods
          end

          private

          def sort_it(entity_type, sort_attribute, sort_direction)
            entity_type.order sort_attribute.to_s => sort_direction
          end
        end
      end
    end
  end
end
