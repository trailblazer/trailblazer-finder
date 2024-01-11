# frozen_string_literal: true

module Trailblazer
  class Finder
    module Activities
      class PrepareProperties < Trailblazer::Activity::Railway
        def check_property_types(_ctx, config:, **)
          properties = config.properties
          return true if properties.empty?

          properties.each do |key, _value|
            return !properties[key][:type].nil?
          end
        end

        def validate_property_types(_ctx, config:, **)
          properties = config.properties
          return true if properties.empty?

          properties.each do |key, _value|
            return properties[key][:type].class.ancestors.include?(::Dry::Types::Nominal)
          end
        end

        def invalid_properties_error(ctx, **)
          (ctx[:errors] ||= []) << {properties: "One or more properties are missing a valid type"}
        end

        def set_properties(ctx, config:, **)
          ctx[:properties] = config.properties
        end

        step :check_property_types
        step :validate_property_types
        fail :invalid_properties_error
        step :set_properties
      end
    end
  end
end
