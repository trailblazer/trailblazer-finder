# frozen_string_literal: true

module Trailblazer
  class Finder
    module Activities
      class ProcessAdapters < Trailblazer::Activity::Railway
        def set_adapter((ctx, _flow_options), **)
          adapter = ctx[:adapter]
          ctx[:orm] = {}
          ctx[:orm][:adapter] = adapter
          ctx[:orm][:predicates] = "Trailblazer::Finder::Adapters::#{adapter}::Predicates"
          ctx[:orm][:paging] = "Trailblazer::Finder::Adapters::#{adapter}::Paging"
          ctx[:orm][:sorting] = "Trailblazer::Finder::Adapters::#{adapter}::Sorting"
          true
        end

        def set_paginator(ctx, **)
          paginator = ctx[:config].paginator
          return true unless paginator
          return false unless EXT_ORM_ADAPTERS.(ctx[:orm][:adapter])
          return false unless PAGING_ADAPTERS.(paginator)

          ctx[:orm][:paging] = "Trailblazer::Finder::Adapters::#{paginator}::Paging"
          true
        end

        def invalid_paginator_error(ctx, **)
          (ctx[:errors] ||= []) << {
            paginator: "Can't use paginator #{ctx[:config].paginator} without using an ORM like ActiveRecord or Sequel"
          }
        end

        def invalid_paginator_handler(_e, (ctx, _flow_options), **)
          invalid_paginator_error(ctx)
        end

        step :set_adapter, fast_track: true
        step Rescue(Dry::Types::ConstraintError, handler: :invalid_paginator_handler) {
          step :set_paginator
          fail :invalid_paginator_error
        }
      end
    end
  end
end
