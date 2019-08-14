# frozen_string_literal: true

module Trailblazer
  class Finder
    module Activity
      # Find Activity
      module Find
        PREDICATES = %w[eq not_eq blank not_blank lt lte gt gte sw not_sw ew not_ew cont not_cont].freeze

        extend Trailblazer::Activity::Railway()

        module_function

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

        def process_params(ctx, **)
          ctx[:params].each do |attribute, value|
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

        step Subprocess(Prepare), id: :prepare_finder
        step method(:process_params), id: :process_params
        step Subprocess(Process), id: :process_finder
        step method(:set_finder), id: :set_finder
      end
    end
  end
end
