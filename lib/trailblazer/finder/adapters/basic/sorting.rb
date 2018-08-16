# frozen_string_literal: true

module Trailblazer
  class Finder
    module Adapters
      # ActiveRecord Adapter
      module Basic
        # Basic Paging Adapter
        module Sorting
          module_function

          def set_sorting_handler # rubocop:disable Metrics/CyclomaticComplexity
            lambda do |sort_attributes, entity|
              sort_attributes.delete(:handler)
              attributes = []
              sort_attributes.each do |attr|
                attributes << [attr[0].to_sym, (attr[1] == :asc ? 1 : -1)]
              end
              entity.sort do |this, that|
                attributes.reduce(0) do |diff, order|
                  next diff if diff != 0 # this and that have differed at an earlier order entry
                  key, direction = order
                  # deal with nil cases
                  next  0 if this[key].nil? && that[key].nil?
                  next  1 if this[key].nil?
                  next -1 if that[key].nil?
                  # do the actual comparison
                  comparison = this[key] <=> that[key]
                  comparison * direction
                end
              end
            end
          end
        end
      end
    end
  end
end
