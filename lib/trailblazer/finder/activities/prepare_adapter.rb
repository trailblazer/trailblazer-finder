# frozen_string_literal: true

module Trailblazer
  class Finder
    module Activities
      class PrepareAdapter < Trailblazer::Activity::Railway
        def set_adapter(ctx, **)
          ctx[:adapter] = ctx.dig(:config, :adapter) || "Basic"
        end

        def validate_adapter(_ctx, adapter:, **)
          ORM_ADAPTERS.(adapter.to_s)
        end

        def invalid?(_e, (ctx, _flow_options), **_circuit_options)
          (ctx[:errors] ||= []) << {adapter: "The specified adapter are invalid"}
        end

        step :set_adapter
        step Rescue(Dry::Types::ConstraintError, handler: :invalid?) {
          step :validate_adapter
        }
      end
    end
  end
end
