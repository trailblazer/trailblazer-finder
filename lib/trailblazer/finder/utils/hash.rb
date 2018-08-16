# frozen_string_literal: true

module Trailblazer
  class Finder
    # Helper module
    module Utils
      module Hash
        module_function

        def deep_locate(comparator, object, result = [])
          if object.is_a?(::Enumerable) && comparator.is_a?(::Proc)
            result.push object if object.any? { |value| match_comparator?(value, comparator, object) }
            (object.respond_to?(:values) ? object.values : object.entries).each do |value|
              deep_locate(comparator, value, result)
            end
          end

          result
        end

        def match_comparator?(value, comparator, object)
          key = nil
          key, value = value if object.is_a?(::Hash)
          comparator.call(key, value, object)
        end

        def remove_keys_from_hash(hash, keys)
          hash.each do |key, _value|
            hash.delete(key) if keys.include?(key)
          end
          hash
        end
      end
    end
  end
end
