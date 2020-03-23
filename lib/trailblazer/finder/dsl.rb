# frozen_string_literal: true

module Trailblazer
  class Finder
    module Dsl
      attr_reader :config

      def inherited(base)
        base.instance_variable_set "@config", apply_config({})
      end

      def entity(&block)
        config[:entity] = block
      end

      def paging(options, **)
        config[:paging][:per_page] = options[:per_page] || 25
        config[:paging][:min_per_page] = options[:min_per_page] || 10
        config[:paging][:max_per_page] = options[:max_per_page] || 100
      end

      def property(name, options = {})
        config[:properties][name] = options
        config[:properties][name][:type] = options[:type] || Types::String
        config[:sorting][name] = options[:sort_direction] || :desc if options[:sortable]
      end

      def filter_by(name, options = {}, &block)
        filter_name = name.to_sym
        config[:filters][filter_name] = {}
        config[:filters][filter_name][:name] = name
        config[:filters][filter_name][:with] = options[:with] if options.include?(:with)
        config[:filters][filter_name][:block] = block || nil
      end

      def adapter(adapter)
        config[:adapter] = adapter.to_s
      end

      def paginator(paginator)
        config[:paginator] = paginator.to_s
      end

      def apply_config(options, **)
        return @config = options unless options.empty?

        @config = {
          actions:    {},
          entity:     nil,
          properties: {},
          filters:    {},
          paging:     {},
          sorting:    {},
          adapters:   []
        }
      end
    end
  end
end
