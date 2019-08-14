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
        config[:filters][name] = {}
        config[:filters][name][:name] = name
        config[:filters][name][:with] = options[:with] if options.include?(:with)
        config[:filters][name][:block] = block || nil
      end

      def adapters(*adapters)
        adapters.each do |adapter|
          config[:adapters].push adapter.to_s.split("::").last.gsub("}>", "") if config[:adapters]
        end
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
