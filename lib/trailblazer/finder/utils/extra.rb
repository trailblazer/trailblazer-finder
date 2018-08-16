# frozen_string_literal: true

module Trailblazer
  class Finder
    # Helper module
    module Utils
      module Extra
        module_function

        def apply_handler(handler, predicate_handler = "Trailblazer::Finder::Adapters::Basic::Predicates")
          case handler
            when Symbol then ->(entity, attribute, value) { method(handler).call entity, attribute, value }
            when Proc then handler
            else
              Object.const_get(predicate_handler).__send__ :set_eq_handler
          end
        end
      end
    end
  end
end
