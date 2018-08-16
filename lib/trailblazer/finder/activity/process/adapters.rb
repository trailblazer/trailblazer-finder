# frozen_string_literal: true

module Trailblazer
  class Finder
    module Activity
      module Process
        # Process Adapters Activity
        module Adapters
          extend Trailblazer::Activity::Railway()

          module_function

          def set_orm(ctx, **)
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

          step method(:set_orm)
        end
      end
    end
  end
end
