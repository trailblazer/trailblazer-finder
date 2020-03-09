# frozen_string_literal: true

module Trailblazer
  class Finder
    module Activities
      class ProcessFilters < Trailblazer::Activity::Railway
        def set_filter_handlers(ctx, **)
          return true unless ctx[:process]

          ctx[:process].each do |key, value|
            next if ctx[:process][key][:filter].nil?

            ctx[:process][key][:handler] = Utils::Extra.apply_handler(value[:filter] ? value[:filter][:handler] : "none")
          end
        end

        step :set_filter_handlers
      end
    end
  end
end
