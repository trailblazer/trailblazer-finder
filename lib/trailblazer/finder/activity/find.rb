# frozen_string_literal: true

module Trailblazer
  class Finder
    module Activity
      # Find Activity
      class Find < Trailblazer::Activity::Railway
        PREDICATES = %w[eq not_eq blank not_blank lt lte gt gte sw not_sw ew not_ew cont not_cont].freeze


        def process_params(ctx, params:,  **)
          params.each do |attribute, value|
            result = {}

            fetch_filters(ctx, result, attribute) || result if ctx[:filters].include?(attribute)
            fetch_properties(result, attribute, value, ctx[:properties]) || result
            next ctx[:params].delete(attribute) if result.empty?

            ctx[:process] ||= {}
            ctx[:process][attribute] = result.merge!(value: value)
          end
          true
        end

        def set_finder(ctx, **)
          ctx[:finder] = Finder::Find.new(ctx[:entity], ctx[:params], ctx[:process], ctx[:paging], ctx[:sorting], ctx[:config])
        end

        step Subprocess(Prepare)
        step :process_params
        step Subprocess(Process)
        step :set_finder

        private
          def fetch_filters(ctx, result, attribute)
            filter_attribute = ctx[:filters][attribute]
            result[:filter] = {}
            result[:name] = attribute
            result[:filter][:handler] = filter_attribute[:with] || filter_attribute[:block]
          end

          def fetch_properties(result, attribute, value, properties)
            splitter = Utils::Splitter.new attribute, value
            PREDICATES.each do |predicate|
              next unless splitter.split_key predicate
              next unless properties.include?(splitter.field.to_sym)

              result[:name] = splitter.field
              result[:predicate] = predicate
            end
          end
      end
    end
  end
end
