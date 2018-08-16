module Trailblazer
  class Finder
    module Adapters
      # WillPaginate Adapter
      module WillPaginate
        def self.included(base)
          base.extend Features::Paging::ClassMethods
        end

        private

        def apply_paging(entity_type)
          entity_type.paginate per_page: per_page, page: page.zero? ? nil : page
        end
      end
    end
  end
end
