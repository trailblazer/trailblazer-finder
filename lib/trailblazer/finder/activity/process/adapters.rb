# frozen_string_literal: true

module Trailblazer
  class Finder
    module Activity
      module Process
        # Process Adapters Activity
        module Adapters
          extend Trailblazer::Activity::Railway()

          module_function

          def set_orm_adapters(ctx, **)
            ctx[:adapters].each do |adapter|
              next unless (ORM_ADAPTERS + ["Basic"]).include?(adapter)

              ctx[:orm] = {}
              ctx[:orm][:adapter] = adapter
              ctx[:orm][:predicates] = "Trailblazer::Finder::Adapters::#{adapter}::Predicates"
              ctx[:orm][:paging] = "Trailblazer::Finder::Adapters::#{adapter}::Paging"
              ctx[:orm][:sorting] = "Trailblazer::Finder::Adapters::#{adapter}::Sorting"
              return true
            end
          end

          def set_paging_adapters(ctx, **)
            ctx[:adapters].each do |adapter|
              next unless PAGING_ADAPTERS.include?(adapter)
              return false if ctx[:adapters].include?("Basic")

              ctx[:orm][:paging] = "Trailblazer::Finder::Adapters::#{adapter}::Paging"
              return true
            end
            true
          end

          def invalid_paging_adapter_error(ctx, **)
            (ctx[:errors] ||= []) << {adapters: "Can't use paging adapters like Kaminari without using an ORM like ActiveRecord or Sequel"}
          end

          step method(:set_orm_adapters)
          step method(:set_paging_adapters)
          fail method(:invalid_paging_adapter_error)
        end
      end
    end
  end
end
