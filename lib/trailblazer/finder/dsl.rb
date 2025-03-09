module Trailblazer
  class Finder
    class Configuration
      attr_reader :state

      def initialize
        @state = Trailblazer::Declarative::State(
          entity: [nil, {}],
          paging: [{}, {}],
          properties: [{}, {}],
          sorting: [{}, {}],
          filters: [{}, {}],
          adapter: ["Basic", {}],
          paginator: [nil, {}]
        )
      end

      # Accessors that delegate to the state
      def entity
        state.get(:entity)
      end

      def entity=(value)
        state.set!(:entity, value)
      end

      def paging
        state.get(:paging)
      end

      def paging=(value)
        state.set!(:paging, value)
      end

      def properties
        state.get(:properties)
      end

      def properties=(value)
        state.set!(:properties, value)
      end

      def sorting
        state.get(:sorting)
      end

      def sorting=(value)
        state.set!(:sorting, value)
      end

      def filters
        state.get(:filters)
      end

      def filters=(value)
        state.set!(:filters, value)
      end

      def adapter
        state.get(:adapter)
      end

      def adapter=(value)
        state.set!(:adapter, value)
      end

      def paginator
        state.get(:paginator)
      end

      def paginator=(value)
        state.set!(:paginator, value)
      end

      # Clone the configuration by copying the state
      def clone
        new_config = Configuration.new
        new_config.instance_variable_set(:@state, @state.copy)
        new_config
      end
    end

    module Dsl
      def config
        @config ||= Configuration.new
      end

      def inherited(base)
        # Skip inheritance for the base Trailblazer::Finder class
        return if name == 'Trailblazer::Finder'

        base.config = config.clone
      end

      def entity(&block)
        config.entity = block
      end

      def paging(per_page: 25, min_per_page: 10, max_per_page: 100)
        config.state.update!(:paging) do |paging|
          paging.merge(per_page: per_page, min_per_page: min_per_page, max_per_page: max_per_page)
        end
      end

      def property(name, options = {})
        config.state.update!(:properties) { |props| props.merge(name => options.merge(type: options[:type] || Types::String)) }
        config.state.update!(:sorting) { |sort| sort.merge(name => (options[:sort_direction] || :desc)) } if options[:sortable]
      end

      def filter_by(name, options = {}, &block)
        filter_name = name.to_sym
        config.state.update!(:filters) do |filters|
          filters.merge(filter_name => { name: name, with: options[:with], block: block }.compact)
        end
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
