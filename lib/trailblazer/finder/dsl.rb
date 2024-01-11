module Trailblazer
  class Finder
    class Configuration
      attr_accessor :entity, :paging, :properties, :sorting,
                    :filters, :adapter, :paginator

      def initialize
        @paging = {}
        @properties = {}
        @sorting = {}
        @filters = {}
        @paginator = nil
        @adapter = "Basic"
      end

      def clone
        new_config = Configuration.new
        new_config.entity = entity
        new_config.paging = paging.clone
        new_config.properties = properties.clone
        new_config.sorting = sorting.clone
        new_config.filters = filters.clone
        new_config.adapter = adapter
        new_config.paginator = paginator
        new_config
      end
    end

    module Dsl
      def config
        @config ||= Configuration.new
      end


      def inherited(base)
        ## We don't want to inherit the config from Trailblazer::Finder
        return if name == 'Trailblazer::Finder'

        base.config = config.clone
      end

      def entity(&block)
        config.entity = block
      end

      def paging(per_page: 25, min_per_page: 10, max_per_page: 100)
        config.paging[:per_page] = per_page
        config.paging[:min_per_page] = min_per_page
        config.paging[:max_per_page] = max_per_page
      end

      def property(name, options = {})
        config.properties[name] = options
        config.properties[name][:type] = options[:type] || Types::String
        config.sorting[name] = options[:sort_direction] || :desc if options[:sortable]
      end

      def filter_by(name, options = {}, &block)
        filter_name = name.to_sym
        config.filters[filter_name] = {}
        config.filters[filter_name][:name] = name
        config.filters[filter_name][:with] = options[:with] if options.include?(:with)
        config.filters[filter_name][:block] = block || nil
      end

      def adapter(adapter_name)
        config.adapter = adapter_name.to_s
      end

      def paginator(paginator_name)
        config.paginator = paginator_name.to_s
      end

      def current_adapter
        config.adapter
      end

      def current_paginator
        config.paginator
      end

      def filters_count
        config.filters.count
      end

      def properties_count
        config.properties.count
      end

      protected

      attr_writer :config
    end
  end
end
