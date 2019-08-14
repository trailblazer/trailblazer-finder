# frozen_string_literal: true

module Trailblazer
  class Finder
    module Activity
      module Prepare
        # Prepare Properties Activity
        module Properties
          extend Trailblazer::Activity::Railway()

          module_function

          def check_property_types(ctx, **)
            properties = ctx[:config][:properties] || {}
            return true if properties.empty?

            properties.each do |key, _value|
              return !properties[key][:type].nil?
            end
          end

          def validate_property_types(ctx, **)
            properties = ctx[:config][:properties] || {}
            return true if properties.empty?

            properties.each do |key, _value|
              return properties[key][:type].class.ancestors.include?(Dry::Types::Definition)
            end
          end

          def invalid_properties_error(ctx, **)
            (ctx[:errors] ||= []) << {properties: "One or more properties are missing a valid type"}
          end

          def set_properties(ctx, **)
            ctx[:properties] = ctx[:config][:properties]
          end

          step method(:check_property_types), id: :check_property_types
          step method(:validate_property_types), id: :validate_property_types
          fail method(:invalid_properties_error), id: :invalid_properties_error
          step method(:set_properties), id: :set_properties
        end
      end
    end
  end
end
