module Trailblazer
  class Finder
    module Adapters
      # Kaminari Adapter
      module Kaminari
        def self.included(base)
          base.extend Features::Paging::ClassMethods
        end

        private

        def apply_paging(entity_type)
          entity_type.page(page).per(per_page)
        end
      end
    end
  end
end
