require 'trailblazer/finder/adapters/sequel/paging'
require 'trailblazer/finder/adapters/sequel/sorting'

module Trailblazer
  class Finder
    module Adapters
      # Sequel Adapter
      module Sequel
        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods
          # :nocov:
          def normalize_find_handler(handler, key)
            case handler
            when Symbol then ->(entity_type, value) { method(handler).call entity_type, value }
            when Proc then handler
            else ->(entity_type, value) { entity_type.where(key.to_sym => value) unless Utils::String.blank?(value) }
            end
          end
          # :nocov:
        end

        include Paging if defined?(Features::Paging::ClassMethods)
        include Sorting if defined?(Features::Sorting::ClassMethods)
      end
    end
  end
end
