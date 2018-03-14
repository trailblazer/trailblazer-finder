module Trailblazer
  class Finder
    # Helper module
    module Utils
      class Extra
        def self.ensure_included(item, collection)
          if collection.include? item
            item
          else
            collection.first
          end
        end

        def self.deep_copy(object)
          case object
          when Array
            object.map { |element| deep_copy(element) }
          when Hash
            object.each_with_object({}) do |(key, value), result|
              result[key] = deep_copy(value)
            end
          when NilClass, FalseClass, TrueClass, Symbol, Method, Numeric
            object
          else
            object.dup
          end
        end
      end
    end
  end
end
