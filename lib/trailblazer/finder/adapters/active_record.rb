require "trailblazer/finder/adapters/active_record/paging"
require "trailblazer/finder/adapters/active_record/sorting"
require "trailblazer/finder/adapters/active_record/predicates"

module Trailblazer
  class Finder
    module Adapters
      # ActiveRecord Adapter
      module ActiveRecord
        def self.included(base)
          base.extend ClassMethods
          base.instance_eval do
            include ActiveRecord::Predicates if defined?(Features::Predicate::ClassMethods)
          end
        end

        module ClassMethods
          def normalize_find_handler(handler, key)
            case handler
              when Symbol then ->(entity_type, value) { method(handler).call entity_type, value }
              when Proc then handler
              else ->(entity_type, value) { entity_type.where(key.to_sym => value) unless Utils::String.blank?(value) }
            end
          end
        end

        include Paging if defined?(Features::Paging::ClassMethods)
        include Sorting if defined?(Features::Sorting::ClassMethods)
      end
    end
  end
end
