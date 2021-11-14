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
            ->(current_page, per_page, entity) do
              entity.drop(([current_page, 1].max - 1) * per_page).first(per_page)
            end
          end
        end
      end
    end
  end
end
