# frozen_string_literal: true

module Trailblazer
  class Finder
    module Activities
      # Turns a finder's class-level config plus the options given to {Finder.new}
      # into a {Finder::Find} query object, or collects an error and fails.
      class Find < Trailblazer::Operation
        PREDICATES = %w[eq not_eq blank not_blank lt lte gt gte sw not_sw ew not_ew cont not_cont].freeze

        step :validate_adapter
        step :set_entity
        step :set_properties
        step :set_filters
        step :set_params
        step :set_paging
        step :set_sorting
        step :process_params
        step :validate_paginator
        step :set_handlers
        step :set_finder

        def validate_adapter(ctx, config:, **)
          ctx[:adapter] = config.adapter
          return true if ORM_ADAPTERS.valid?(config.adapter.to_s)

          error(ctx, adapter: "The specified adapter is invalid")
        end

        def set_entity(ctx, config:, options:, **)
          return error(ctx, entity: "Invalid entity specified") unless options[:entity] || config.entity

          ctx[:entity] = options[:entity] || instance_eval(&config.entity)
        end

        # Only the first property's type is checked, as it always was.
        def set_properties(ctx, config:, **)
          property = config.properties.values.first
          if property && !property[:type].is_a?(::Dry::Types::Nominal)
            return error(ctx, properties: "One or more properties are missing a valid type")
          end

          ctx[:properties] = config.properties
        end

        def set_filters(ctx, config:, **)
          unless config.filters.each_value.all? { |filter| filter[:with].nil? || filter[:with].is_a?(Symbol) }
            return error(ctx, filters: "One or more filters are missing a with method definition")
          end

          ctx[:filters] = config.filters
        end

        def set_params(ctx, options:, **)
          ctx[:params] = options[:params] || {}
        end

        def set_paging(ctx, config:, params:, **)
          if config.paging.empty?
            params.delete(:page)
            return true
          end

          paging = config.paging.dup
          paging[:current_page] = params[:page] || 1
          if params[:per_page]
            per_page = [params[:per_page].to_i, paging[:max_per_page]].min
            paging[:per_page] = [per_page, paging[:min_per_page]].max
          end
          ctx[:paging] = paging
        end

        def set_sorting(ctx, config:, params:, **)
          if config.sorting.empty?
            params.delete(:sort)
            return true
          end
          return true if params[:sort].nil?

          ctx[:sorting] = params[:sort].split(",").each_with_object({}) do |sorter, sorting|
            name, direction = sorter.split
            next unless name && config.sorting.include?(name.to_sym)

            sorting[name] = sort_direction(config.sorting[name.to_sym], direction)
          end
        end

        # Maps every param to the filter or property predicate handling it and drops the params nobody handles.
        def process_params(ctx, params:, filters:, properties:, **)
          process = {}
          params.to_a.each do |attribute, value|
            name = attribute.to_sym
            entry = filters.include?(name) ? filter_entry(filters[name], name) : {}
            entry.merge!(predicate_entry(attribute, value, properties))
            next params.delete(attribute) if entry.empty?

            process[name] = entry.merge!(value: value)
          end
          ctx[:process] = process unless process.empty?
          true
        end

        def validate_paginator(ctx, config:, adapter:, **)
          paginator = config.paginator or return true
          return true if EXT_ORM_ADAPTERS.valid?(adapter) && PAGING_ADAPTERS.valid?(paginator)

          error(ctx, paginator: "Can't use paginator #{paginator} without using an ORM like ActiveRecord or Sequel")
        end

        def set_handlers(_ctx, config:, adapter:, process: nil, paging: nil, sorting: nil, **)
          orm = Adapters.const_get(adapter)

          process&.each_value do |entry|
            entry[:handler] = Utils::Extra.apply_handler(
              entry[:filter] ? entry[:filter][:handler] : orm::Predicates.public_send(:"set_#{entry[:predicate]}_handler")
            )
          end
          paging[:handler] = Adapters.const_get(config.paginator || adapter)::Paging.set_paging_handler if paging
          sorting[:handler] = orm::Sorting.set_sorting_handler if sorting
          true
        end

        def set_finder(ctx, entity:, params:, config:, process: nil, paging: nil, sorting: nil, **)
          ctx[:finder] = Finder::Find.new(entity, params, process, paging, sorting, config)
        end

        private

        def error(ctx, **error)
          (ctx[:errors] ||= []) << error
          false
        end

        def sort_direction(config_direction, params_direction)
          return config_direction == :asc ? :asc : :desc if params_direction.nil?

          %w[asc :asc].include?(params_direction) ? :asc : :desc
        end

        def filter_entry(filter, name)
          {filter: {handler: filter[:with] || filter[:block]}, name: name}
        end

        # The last predicate matching both the key's suffix and a declared property wins.
        def predicate_entry(attribute, value, properties)
          splitter = Utils::Splitter.new(attribute, value)
          PREDICATES.each_with_object({}) do |predicate, entry|
            next unless splitter.split_key(predicate) && properties.include?(splitter.field.to_sym)

            entry[:name] = splitter.field
            entry[:predicate] = predicate
          end
        end
      end
    end
  end
end
