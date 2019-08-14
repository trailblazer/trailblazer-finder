# frozen_string_literal: true

module Trailblazer
  class Finder
    module Activity
      module Process
        # Process Paging Activity
        module Paging
          extend Trailblazer::Activity::Railway()

          module_function

          def set_paging_handler(ctx, **)
            return true if ctx[:paging].nil?

            ctx[:paging][:handler] = Utils::Extra.apply_handler(
              (Object.const_get(ctx[:orm][:paging]).__send__ :set_paging_handler)
            )
          end

          step method(:set_paging_handler), id: :set_paging_handler
        end
      end
    end
  end
end
