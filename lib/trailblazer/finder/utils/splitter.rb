module Trailblazer
  class Finder
    # Helper module
    module Utils
      class Splitter
        def initialize(key, value)
          @key, @value = key, value
        end

        attr_reader :key, :value

        # split suffix from the key and store the two values as name and op
        # return truthy if successful
        def split_key(suffix)
          rv = @key =~ /\A(?:(.*?)_)?(#{suffix})\z/
          @field, @op = $1, $2
          rv
        end

        alias_method :===, :split_key
        alias_method :=~, :split_key

        # return name if the split was successful, or fall back to key
        # which is handy when none of the predicates match and so key
        # is probably just a field name.
        def field
          (@field || @key)
        end

        # the operator, or predicate
        def op
          @op.to_sym
        end

        # the value
        def value
          @value.to_s
        end
      end
    end
  end
end
