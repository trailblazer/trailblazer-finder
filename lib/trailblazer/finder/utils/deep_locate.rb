module Trailblazer
  class Finder
    module Utils
      module DeepLocate
        def self.deep_locate(comparator, object)
          comparator = _construct_key_comparator(comparator, object) unless comparator.respond_to?(:call)

          _deep_locate(comparator, object)
        end

        def self._construct_key_comparator(search_key, object)
          search_key = search_key.to_s if defined?(::ActiveSupport::HashWithIndifferentAccess) && object.is_a?(::ActiveSupport::HashWithIndifferentAccess)
          search_key = search_key.to_s if object.respond_to?(:indifferent_access?) && object.indifferent_access?

          lambda do |non_callable_object|
            ->(key, _, _) { key == non_callable_object }
          end.call(search_key)
        end

        def self._deep_locate(comparator, object, result = [])
          if object.is_a?(::Enumerable)
            if object.any? { |value| _match_comparator?(value, comparator, object) }
              result.push object
            end
            (object.respond_to?(:values) ? object.values : object.entries).each do |value|
              _deep_locate(comparator, value, result)
            end
          end

          result
        end

        def self._match_comparator?(value, comparator, object)
          if object.is_a?(::Hash)
            key, value = value
          else
            key = nil
          end

          comparator.call(key, value, object)
        end
      end
    end
  end
end
