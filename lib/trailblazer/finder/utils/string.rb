require 'date'

module Trailblazer
  class Finder
    # Helper module
    module Utils
      class String
        def self.blank?(value)
          return false if num?(value)
          value.nil? || value.strip.empty?
        end

        def self.num?(str)
          Integer(str)
        rescue ArgumentError, TypeError
          false
        end

        def self.camelize(text)
          text.to_s.gsub(/(?:^|_)(.)/) { Regexp.last_match[1].upcase }
        end

        def self.underscore(text)
          text
            .to_s.gsub(/::/, '/')
            .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
            .gsub(/([a-z\d])([A-Z])/, '\1_\2')
            .tr('-', '_')
            .tr(' ', '_')
            .downcase
        end
      end
    end
  end
end
