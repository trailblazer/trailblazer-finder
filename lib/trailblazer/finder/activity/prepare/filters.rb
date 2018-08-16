# frozen_string_literal: true

module Trailblazer
  class Finder
    module Activity
      module Prepare
        # Filters Activity
        module Filters
          extend Trailblazer::Activity::Railway()

          module_function

          def validate_filters(ctx, **)
            filters = ctx[:config][:filters]
            filters.each do |key, _value|
              return false if !filters[key][:with].nil? && !filters[key][:with].is_a?(Symbol)
            end
            true
          end

          def invalid_filters_error(ctx, **)
            (ctx[:errors] ||= []) << {filters: "One or more filters are missing a with method definition"}
          end

          def set_filters(ctx, **)
            ctx[:filters] = ctx[:config][:filters]
          end

          step method(:validate_filters), id: :validate_filters
          fail method(:invalid_filters_error), id: :invalid_filters_error
          step method(:set_filters), id: :set_filters
        end
      end
    end
  end
end
