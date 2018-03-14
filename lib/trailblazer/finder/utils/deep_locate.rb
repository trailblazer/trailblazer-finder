module Trailblazer
  class Finder
    module Utils
      module DeepLocate
        def self.deep_locate(comparator, object)
          _deep_locate(comparator, object)
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
