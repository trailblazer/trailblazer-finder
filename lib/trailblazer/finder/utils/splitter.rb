# frozen_string_literal: true

module Trailblazer
  class Finder
    # Helper module
    module Utils
      class Splitter
        attr_reader :key, :value

        def initialize(key, value)
          @key = key
          @value = value.to_s
        end

        # split suffix from the key and store the two values as name and op
        # return truthy if successful
        def split_key(suffix)
          rv = @key =~ /\A(?:(.*?)_)?(#{suffix})\z/
          @field = Regexp.last_match(1)
          @predicate = Regexp.last_match(2)
          !rv.nil?
        end

        alias === split_key
        alias =~ split_key

        # return name if the split was successful, or fall back to key
        # which is handy when none of the predicates match and so key
        # is probably just a field name.
        def field
          (@field || @key)
        end

        # the predicate
        def predicate
          @predicate.to_sym
        end
      end
    end
  end
end
