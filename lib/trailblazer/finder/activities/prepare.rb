# frozen_string_literal: true

module Trailblazer
  class Finder
    module Activities
      class Prepare < Trailblazer::Activity::Railway
        def clean_ctx((ctx, flow_options), **)
          ctx.delete(:options)
          [Activity::Right, [ctx, flow_options]]
        end

        step Subprocess(PrepareAdapter)
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
