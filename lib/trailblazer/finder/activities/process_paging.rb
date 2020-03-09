# frozen_string_literal: true

module Trailblazer
  class Finder
    module Activities
      class ProcessPaging < Trailblazer::Activity::Railway
        def set_paging_handler(ctx, **)
          return true if ctx[:paging].nil?

          ctx[:paging][:handler] = Utils::Extra.apply_handler(
            (Object.const_get(ctx[:orm][:paging]).__send__ :set_paging_handler)
          )
        end

        step :set_paging_handler
      end
    end
  end
end
