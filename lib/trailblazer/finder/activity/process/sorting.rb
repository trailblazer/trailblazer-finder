# frozen_string_literal: true

module Trailblazer
  class Finder
    module Activity
      module Process
        # Process sorting Activity
        module Sorting
          extend Trailblazer::Activity::Railway()

          module_function

          def set_sorting_handler(ctx, **)
            return true if ctx[:sorting].nil?
            ctx[:sorting][:handler] = Utils::Extra.apply_handler(
              (Object.const_get(ctx[:orm][:sorting]).__send__ :set_sorting_handler)
            )
          end

          step method(:set_sorting_handler), id: :set_sorting_handler
        end
      end
    end
  end
end
