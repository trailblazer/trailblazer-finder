# frozen_string_literal: true

module Trailblazer
  class Finder
    module Activity
      module Prepare
        # Adapters Activity
        module Adapters
          extend Trailblazer::Activity::Railway()

          module_function

          def check_for_adapters(ctx, **)
            adapters = ctx[:config][:adapters]
            return true if adapters.empty?
            adapters.each do |adapter|
              return true if Finder::Adapters.constants.include?(adapter.to_sym)
            end
            false
          end

          def validate_adapters(ctx, **)
            adapters = ctx[:config][:adapters]
            return true if adapters.empty?
            adapters.each do |adapter|
              if ORM_ADAPTERS.include?(adapter)
                return false if (adapters & (ORM_ADAPTERS - [adapter])).present?
              end
            end
          end

          def invalid_adapters_error(ctx, **)
            (ctx[:errors] ||= []) << {adapters: "One or more of the specified adapters are invalid"}
          end

          def multiple_orm_error(ctx, **)
            (ctx[:errors] ||= []) << {adapters: "More then one ORM adapter specified"}
          end

          def set_adapters(ctx, **)
            adapters = ctx[:config][:adapters]
            ctx[:adapters] = adapters.empty? ? ["Basic"] : adapters
          end

          step method(:check_for_adapters),
            Output(:success) => Track(:valid),
            Output(:failure) => Track(:invalid_adapters)
          step method(:validate_adapters), magnetic_to: [:valid],
            Output(:success) => Track(:valid),
            Output(:failure) => Track(:multiple_orm)
          fail method(:invalid_adapters_error), magnetic_to: [:invalid_adapters],
            Output(:success) => Track(:failure),
            Output(:failure) => Track(:failure)
          fail method(:multiple_orm_error), magnetic_to: [:multiple_orm],
            Output(:success) => Track(:failure),
            Output(:failure) => Track(:failure)
          step method(:set_adapters), magnetic_to: [:valid],
            Output(:success) => Track(:success),
            Output(:failure) => Track(:failure)
        end
      end
    end
  end
end
