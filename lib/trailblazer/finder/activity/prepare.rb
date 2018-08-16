# frozen_string_literal: true

module Trailblazer
  class Finder
    module Activity
      # Prepare Activity
      module Prepare
        extend Trailblazer::Activity::Railway()

        module_function

        def clean_ctx((ctx, flow_options), **)
          # ctx.delete(:config)
          ctx.delete(:options)
          [Trailblazer::Activity::Right, [ctx, flow_options]]
        end

        step Subprocess(Prepare::Entity), id: :prepare_entity
        step Subprocess(Prepare::Properties), id: :prepare_properties
        step Subprocess(Prepare::Filters), id: :prepare_filters
        step Subprocess(Prepare::Params), id: :prepare_params
        step Subprocess(Prepare::Adapters), id: :prepare_adapters
        step Subprocess(Prepare::Paging), id: :prepare_paging
        step Subprocess(Prepare::Sorting), id: :prepare_sorting
        step method(:clean_ctx), id: :clean_ctx
      end
    end
  end
end
