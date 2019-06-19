# frozen_string_literal: true

require_relative "prepare_adapters"
require_relative "prepare_entity"
require_relative "prepare_properties"
require_relative "prepare_filters"
require_relative "prepare_params"
require_relative "prepare_paging"
require_relative "prepare_sorting"

module Trailblazer
  class Finder
    module Activity
      # Prepare Activity
      class Prepare < Trailblazer::Activity::Railway
        def clean_ctx((ctx, flow_options), **)
          ctx.delete(:options)
          [Trailblazer::Activity::Right, [ctx, flow_options]]
        end

        step Subprocess(PrepareAdapters)
        step Subprocess(PrepareEntity)
        step Subprocess(PrepareProperties)
        step Subprocess(PrepareFilters)
        step Subprocess(PrepareParams)
        step Subprocess(PreparePaging)
        step Subprocess(PrepareSorting)
        step :clean_ctx
      end
    end
  end
end
