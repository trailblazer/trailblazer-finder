# frozen_string_literal: true

module Trailblazer
  class Finder
    module Activities
      class PrepareAdapter < Trailblazer::Activity::Railway
        def set_adapter(ctx, **)
          ctx[:adapter] = ctx[:config].adapter
        end

        def validate_adapter(_ctx, adapter:, **)
          ORM_ADAPTERS.(adapter.to_s)
        end

        def invalid?(exception, (ctx, _flow_options), **_circuit_options)
          (ctx[:errors] ||= []) << {adapter: "The specified adapter is invalid"}
          true # Make sure to return true to indicate the handler handled the error
        end

        pass :set_adapter
        step Rescue(Dry::Types::ConstraintError, handler: :invalid?) {
          step :validate_adapter
        }, Output(:failure) => End(:failure)
      end
    end
  end
end