require 'date'

module Trailblazer
  class Finder
    # Helper module
    module Utils
      class Parse
        # Need a replacement for this
        def self.date(value)
          return unless is_datetime(value)
          Date.parse(value).strftime('%Y-%m-%d')
        rescue ArgumentError
          nil
        end

        def self.is_datetime(d)
          %w[Date Time DateTime Timezone].any? { |t| d.class.name == t }
        end

        def self.term(value)
          "%#{value.gsub(/\s+/, '%')}%"
        end
      end
    end
  end
end
