module Trailblazer
  class Finder
    module Adapters
      module Sequel
        # Sequel - Sorting Adapter
        module Sorting
          def self.included(base)
            base.extend Features::Sorting::ClassMethods
          end

          private

          def sort_orders(sort_attr, sort_dir)
            ::Sequel.send sort_dir, sort_attr.to_sym
          end

          def sort_it(entity_type, sort_attributes)
            result = []
            result << [:order, sort_attributes.first] if sort_attributes.is_a? Array
            sort_attributes.drop(1).each { |x| result << [:order_append, x] }
            result.inject(entity_type) { |obj, method_and_args| obj.send(*method_and_args) }
          end
        end
      end
    end
  end
end
