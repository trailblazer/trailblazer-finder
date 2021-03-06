# frozen_string_literal: true

module Trailblazer
  class Finder
    module Adapters
      # ActiveRecord Adapter
      module Basic
        # Basic Paging Adapter
        module Paging
          module_function

          def set_paging_handler
            lambda do |current_page, per_page, entity|
              entity.drop(([current_page, 1].max - 1) * per_page).first(per_page)
            end
          end
        end
      end
    end
  end
end
