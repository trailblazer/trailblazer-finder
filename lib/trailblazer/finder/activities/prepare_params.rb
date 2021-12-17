# frozen_string_literal: true

module Trailblazer
  class Finder
    module Activities
      # Params Activity
      class PrepareParams < Trailblazer::Activity::Railway
        def validate_params(_ctx, **)
          # Should probably validate some things here at some point
          true
        end

        def invalid_params_error(_ctx, **)
          # (ctx[:errors] ||= []) << {params: "One or more parameters are invalid"}
        end

        def set_params(ctx, **)
          original_params = ctx[:options][:params] || {}
          ctx[:params] = (original_params.respond_to? :to_unsafe_h) ? original_params.to_unsafe_h : original_params
        end

        step :validate_params
        fail :invalid_params_error
        step :set_params
      end
    end
  end
end
