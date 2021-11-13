# frozen_string_literal: true

module Trailblazer
  class Finder
    module Activities
      class Find < Trailblazer::Activity::Railway
        PREDICATES = %w[eq not_eq blank not_blank lt lte gt gte sw not_sw ew not_ew cont not_cont].freeze

        def process_params(ctx, params:, **)
          params.each do |attribute, value|
            result = {}
            filter_attribute = attribute.to_sym
            fetch_filters(ctx, result, filter_attribute) || result if ctx[:filters].include?(filter_attribute)
            fetch_properties(result, filter_attribute, value, ctx[:properties]) || result
            next ctx[:params].delete(attribute) if result.empty?

            ctx[:process] ||= {}
            ctx[:process][filter_attribute] = result.merge!(value: value)
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
