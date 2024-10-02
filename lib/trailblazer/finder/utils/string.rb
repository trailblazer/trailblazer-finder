# frozen_string_literal: true

module Trailblazer
  class Finder
    # Helper module
    module Utils
      class String
        def self.blank?(string)
          return false if numeric?(string)

          string.nil? || string.strip.empty?
        end

        def self.numeric?(string)
          !Float(string).nil?
        rescue StandardError
          false
        end

        def self.camelize(text)
          text.to_s.gsub(/(?:^|_)(.)/) { Regexp.last_match[1].upcase }
        end

        def self.underscore(text)
          text
            .to_s.gsub(/::/, "/")
            .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
            .gsub(/([a-z\d])([A-Z])/, '\1_\2')
            .tr("-", "_")
            .tr(" ", "_")
            .downcase
        end
      end
    end
  end
end
