# frozen_string_literal: true

module Trailblazer
  class Finder
    module Activities
      class ProcessAdapters < Trailblazer::Activity::Railway
        def set_adapter((ctx, flow_options), **)
          adapter = ctx[:adapter]
          ctx[:orm] = {}
          ctx[:orm][:adapter] = adapter
          ctx[:orm][:predicates] = "Trailblazer::Finder::Adapters::#{adapter}::Predicates"
          ctx[:orm][:paging] = "Trailblazer::Finder::Adapters::#{adapter}::Paging"
          ctx[:orm][:sorting] = "Trailblazer::Finder::Adapters::#{adapter}::Sorting"
          true
        end

        def set_paginator(ctx, **)
          paginator = ctx.dig(:config, :paginator)
          return true unless paginator
          return false unless ORM_ADAPTERS.include?(ctx[:orm][:adapter])
          return false unless PAGING_ADAPTERS.include?(paginator)
          ctx[:orm][:paging] = "Trailblazer::Finder::Adapters::#{paginator}::Paging"
          true
        end

        def invalid_paginator_error(ctx, **)
          (ctx[:errors] ||= []) << {paginator: "Can't use paginator #{ctx.dig(:config, :paginator)} without using an ORM like ActiveRecord or Sequel"}
        end

        step :set_adapter, fast_track: true
        step :set_paginator
        fail :invalid_paginator_error
      end
    end
  end
end
