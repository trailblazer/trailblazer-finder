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

          def sort_it(entity_type, sort_attributes)
            entity_type.order(sort_attributes)
          end

          def sort_orders(sort_attr, sort_dir)
            { sort_attr.to_s => sort_dir }
          end
        end
      end
    end
  end
end
