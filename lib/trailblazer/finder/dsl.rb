module Trailblazer
  class Finder
    module Dsl
      def config
        @config ||= Configuration.new
      end

      def inherited(base)
        super
        # Skip inheritance for the base Trailblazer::Finder class
        return if name == 'Trailblazer::Finder'

        base.config = config.clone
      end

      def entity(&block)
        config.entity = block
      end

      def paging(per_page: 25, min_per_page: 10, max_per_page: 100)
        config.paging = config.paging.merge(per_page: per_page, min_per_page: min_per_page, max_per_page: max_per_page)
      end

      def property(name, options = {})
        config.properties = config.properties.merge(name => options.merge(type: options[:type] || Types::String))
        config.sorting = config.sorting.merge(name => (options[:sort_direction] || :desc)) if options[:sortable]
      end

      def filter_by(name, options = {}, &block)
        config.filters = config.filters.merge(name.to_sym => { name: name, with: options[:with], block: block }.compact)
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
