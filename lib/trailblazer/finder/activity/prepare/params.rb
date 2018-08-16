# frozen_string_literal: true

module Trailblazer
  class Finder
    module Activity
      module Prepare
        # Params Activity
        module Params
          extend Trailblazer::Activity::Railway()

          module_function

          def validate_params(_ctx, **)
            # Should probably validate some things here at some point
            true
          end

          def invalid_params_error(ctx, **)
            # (ctx[:errors] ||= []) << {params: "One or more parameters are invalid"}
          end

          def set_params(ctx, **)
            ctx[:params] = ctx[:options][:params] || {}
          end

          step method(:validate_params), id: :validate_params
          fail method(:invalid_params_error), id: :invalid_params_error
          step method(:set_params), id: :set_params
        end
      end
    end
  end
end
