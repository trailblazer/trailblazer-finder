# frozen_string_literal: true

module Trailblazer
  class Finder
    module Adapters
      # ActiveRecord Adapter
      module Sequel
        # ActiveRecord Paging Adapter
        module Sorting
          module_function

          def set_sorting_handler
            ->(sort_attributes, entity) do
              sort_attributes.delete(:handler)
              attributes = []
              sort_attributes.each do |attr|
                attributes << (::Sequel.send attr[1], attr[0].to_sym)
              end
              result = []
              result << [:order, attributes.first] if attributes.is_a? Array
              attributes.drop(1).each { |x| result << [:order_append, x] }
              result.reduce(entity) { |obj, method_and_args| obj.send(*method_and_args) }
            end
          end
        end
      end
    end
  end
end
