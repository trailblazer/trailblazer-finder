# frozen_string_literal: true

module Trailblazer
  class Finder
    # Class-level settings of a finder. Subclasses get their own copy, see {Dsl#inherited}.
    class Configuration
      attr_accessor :entity, :paging, :properties, :sorting, :filters, :adapter, :paginator

      def initialize
        @entity = nil
        @paging = {}
        @properties = {}
        @sorting = {}
        @filters = {}
        @adapter = "Basic"
        @paginator = nil
      end

      def initialize_copy(source)
        super
        @paging = source.paging.dup
        @properties = source.properties.dup
        @sorting = source.sorting.dup
        @filters = source.filters.dup
      end

      def [](name)
        public_send(name)
      end
    end
  end
end
