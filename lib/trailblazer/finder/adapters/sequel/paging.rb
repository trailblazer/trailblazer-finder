module Trailblazer
  class Finder
    module Adapters
      module Sequel
        # Sequel - Paging Adapter
        module Paging
          def self.included(base)
            base.extend Features::Paging::ClassMethods
          end

          private

          def apply_paging(entity_type)
            entity_type.limit(per_page).offset(([page, 1].max - 1) * per_page)
          end
        end
      end
    end
  end
end
