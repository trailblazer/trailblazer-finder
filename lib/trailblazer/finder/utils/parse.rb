require 'date'

module Trailblazer
  class Finder
    # Helper module
    module Utils
      class Parse
        # Need a replacement for this
        def self.date(value)
          return if value.nil?
          return if [true, false].include? value
          return if value.is_a? Integer
          return if value =~ /[[:alpha:]]/
          Date.parse(value).strftime('%Y-%m-%d')
        rescue ArgumentError
          nil
        end

        def self.term(value)
          "%#{value.gsub(/\s+/, '%')}%"
        end
      end
    end
  end
end
