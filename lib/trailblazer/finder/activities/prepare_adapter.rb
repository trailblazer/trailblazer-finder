# frozen_string_literal: true

module Trailblazer
  class Finder
    module Activities
      class PrepareAdapter < Trailblazer::Activity::Railway
        def set_adapter(ctx, **)
          ctx[:adapter] = ctx[:config].adapter
        end

        def validate_adapter(ctx, adapter:, **)
          begin
            ORM_ADAPTERS.(adapter.to_s)
            true
          rescue Dry::Types::ConstraintError
            (ctx[:errors] ||= []) << {adapter: "The specified adapter is invalid"}
            false
          end
        end

        step :set_adapter
        step :validate_adapter
      end
    end
  end
end