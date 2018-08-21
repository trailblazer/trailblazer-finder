# frozen_string_literal: true

module Trailblazer
  class Finder
    module Adapters
      # ActiveRecord Adapter
      module WillPaginate
        # Kaminari Paging Adapter
        module Paging
          module_function

          def set_paging_handler
            lambda do |current_page, per_page, entity|
              entity.paginate per_page: per_page, page: current_page.zero? ? nil : current_page
            end
          end
        end
      end
    end
  end
end
