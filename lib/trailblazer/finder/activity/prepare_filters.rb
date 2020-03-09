# frozen_string_literal: true

module Trailblazer
  class Finder
    module Activity
      class PrepareFilters < Trailblazer::Activity::Railway
        def validate_filters(ctx, **)
          filters = ctx.dig(:config, :filters)
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

        step :validate_filters
        fail :invalid_filters_error
        step :set_filters
      end
    end
  end
end
