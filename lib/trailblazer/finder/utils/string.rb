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

        def self.to_date(value)
          Date.parse(value).strftime("%Y-%m-%d") if date?(value)
        end

        def self.date?(date)
          return false unless
              date.is_a?(::DateTime) ||
              date.is_a?(::Date) ||
              date.is_a?(::String)
          return false if date.is_a?(::String) && date.size == 36 # Ignore uuids that could get casted to dates

          date_hash = ::Date._parse(date.to_s)
          Date.valid_date?(date_hash[:year].to_i, date_hash[:mon].to_i, date_hash[:mday].to_i)
        end
      end
    end
  end
end
