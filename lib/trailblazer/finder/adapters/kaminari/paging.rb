# frozen_string_literal: true

module Trailblazer
  class Finder
    module Adapters
      # ActiveRecord Adapter
      module Kaminari
        # Kaminari Paging Adapter
        module Paging
          module_function

          def set_paging_handler
            lambda do |current_page, per_page, entity|
              entity.page(current_page).per(per_page)
            end
          end
        end
      end
    end
  end
end
