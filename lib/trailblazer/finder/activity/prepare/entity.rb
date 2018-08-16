# frozen_string_literal: true

module Trailblazer
  class Finder
    module Activity
      module Prepare
        # Prepare Entity Activity
        module Entity
          extend Trailblazer::Activity::Railway()

          module_function

          def validate_entity(ctx, **)
            ctx[:options][:entity] || ctx[:config][:entity]
          end

          def invalid_entity_error(ctx, **)
            (ctx[:errors] ||= []) << {entity: "Invalid entity specified"}
          end

          def set_entity(ctx, **)
            ctx[:entity] = ctx[:options][:entity] || instance_eval(&ctx[:config][:entity])
          end

          step method(:validate_entity), id: :validate_entity
          fail method(:invalid_entity_error), id: :invalid_entity_error
          step method(:set_entity), id: :set_entity
        end
      end
    end
  end
end
