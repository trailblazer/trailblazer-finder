# frozen_string_literal: true

module Trailblazer
  class Finder
    class Find
      attr_reader :params, :paging, :sorting, :filters, :config

      def initialize(entity, params, filters, paging = nil, sorting = nil, config = nil)
        @entity   = entity
        @filters  = filters
        @params   = params
        @paging   = paging || {}
        @sorting = sorting || {}
        @config = config || {}
      end

      def process_filters(ctx)
        @params.reduce(@entity) do |entity, (name, value)|
          value = Utils::String.to_date(value) if Utils::String.date?(value)
          filter = @filters[name.to_sym] || @filters[name]
          new_entity = ctx.instance_exec entity, filter[:name], value, &filter[:handler]
          new_entity || entity
        end
      end

      def process_paging(ctx)
        ctx.instance_exec @paging[:current_page], @paging[:per_page], (@sorting.empty? ? (process_filters ctx) : (process_sorting ctx)), &@paging[:handler]
      end

      def process_sorting(ctx)
        ctx.instance_exec @sorting, (process_filters ctx), &@sorting[:handler]
      end

      def query(ctx)
        return process_paging ctx unless @paging.empty? || @paging.nil?
        return process_sorting ctx unless @sorting.empty? || @sorting.nil?

        process_filters ctx
      end
    end
  end
end
