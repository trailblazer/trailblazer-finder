# frozen_string_literal: true

module Trailblazer
  class Finder
    module Activity
      # Adapters Activity
      class PrepareAdapters < Trailblazer::Activity::Railway
        def check_for_adapters(ctx, **)
          adapters = ctx.dig(:config, :adapters)
          return true if adapters.empty?

          adapters.each do |adapter|
            return true if Finder::Adapters.constants.include?(adapter.to_sym)
          end
          false
        end

        ## Only one ORM can be accepted
        def validate_adapters(ctx, **)
          adapters = ctx.dig(:config, :adapters)
          return true if adapters.empty?

          adapters.each do |adapter|
            if ORM_ADAPTERS.include?(adapter)
              return false if (adapters & (ORM_ADAPTERS - [adapter])).any?
            end
          end
          true
        end

        def invalid_adapters_error((ctx, flow_options), **_circuit_options)
          (ctx[:errors] ||= []) << {adapters: "One or more of the specified adapters are invalid"}
        end

        def multiple_orm_error((ctx, flow_options), **_circuit_options)
          (ctx[:errors] ||= []) << {adapters: "More then one ORM adapter specified"}
        end

        def set_adapters(ctx, **)
          adapters = ctx.dig(:config, :adapters)
          ctx[:adapters] = (ORM_ADAPTERS & adapters).any? ? adapters : ["Basic"] + adapters
        end

        step :check_for_adapters
        fail :invalid_adapters_error, Output(:success) => End(:failure)
        step :validate_adapters
        fail :multiple_orm_error
        step :set_adapters
      end
    end
  end
end
