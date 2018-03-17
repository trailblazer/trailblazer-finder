require 'trailblazer/finder/adapters/data_mapper/paging'
# require 'trailblazer/finder/adapters/data_mapper/sorting'

module Trailblazer
  class Finder
    module Adapters
      # ActiveRecord Adapter
      module DataMapper
        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods
          def normalize_find_handler(handler, key)
            case handler
            when Symbol then ->(entity_type, value) { method(handler).call entity_type, value }
            when Proc then handler
            else ->(entity_type, value) { entity_type.all(key.to_sym => value) unless Utils::String.blank?(value) }
            end
          end
        end

        include Paging if defined?(Features::Paging::ClassMethods)
        # include Sorting if defined?(Features::Sorting::ClassMethods)
      end
    end
  end
end
