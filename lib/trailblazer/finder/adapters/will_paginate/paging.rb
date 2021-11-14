# frozen_string_literal: true

module Trailblazer
  class Finder
    module Adapters
      module WillPaginate
        # Kaminari Paginator
        module Paging
          module_function

          def set_paging_handler
            ->(current_page, per_page, entity) do
              entity.paginate per_page: per_page, page: current_page.zero? ? nil : current_page
            end
          end
        end
      end
    end
  end
end
