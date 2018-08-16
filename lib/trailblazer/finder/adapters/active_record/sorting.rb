# frozen_string_literal: true

module Trailblazer
  class Finder
    module Adapters
      # ActiveRecord Adapter
      module ActiveRecord
        # ActiveRecord Paging Adapter
        module Sorting
          module_function

          def set_sorting_handler
            lambda do |sort_attributes, entity|
              sort_attributes.delete(:handler)
              attributes = []
              sort_attributes.each do |attr|
                attributes << {attr[0].to_s => attr[1]}
              end
              entity.order(attributes)
            end
          end
        end
      end
    end
  end
end
