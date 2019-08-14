# frozen_string_literal: true

module Trailblazer
  class Finder
    module Activity
      module Process
        # Process Predicates Activity
        module Predicates
          extend Trailblazer::Activity::Railway()

          module_function

          def set_properties_handler(ctx, **)
            return true if ctx[:process].nil?

            ctx[:process].each do |key, _value|
              next if ctx[:process][key][:predicate].nil?

              ctx[:process][key][:handler] = Utils::Extra.apply_handler(
                (Object.const_get(ctx[:orm][:predicates]).__send__ "set_#{ctx[:process][key][:predicate]}_handler".to_sym)
              )
            end
          end

          step method(:set_properties_handler), id: :set_properties_handler
        end
      end
    end
  end
end
