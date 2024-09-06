# frozen_string_literal: true

module Trailblazer
  class Finder
    module Activities
      class PrepareEntity < Trailblazer::Activity::Railway
        def validate_entity(ctx, config:, **)
          ctx.dig(:options, :entity) || config.entity
        end

        def invalid_entity_error(ctx, **)
          (ctx[:errors] ||= []) << {entity: "Invalid entity specified"}
        end

        def set_entity(ctx, config:, **)
          ctx[:entity] = ctx.dig(:options, :entity)  || instance_eval(&config.entity)
        end

        step :validate_entity
        left :invalid_entity_error
        step :set_entity
      end
    end
  end
end
