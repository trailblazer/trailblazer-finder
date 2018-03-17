module Trailblazer
  class Finder
    module Features
      module Predicate
        PREDICATES = %w[eq not_eq blank not_blank lt lte gt gte sw not_sw ew not_ew cont not_cont].freeze

        def self.included(base)
          base.extend ClassMethods
          base.instance_eval do
            include Predicates
          end
        end

        module ClassMethods
          def predicate_filter(attribute, predicate)
            filter_by "#{attribute}_#{predicate}" do |entity_type, value|
              splitter = Utils::Splitter.new "#{attribute}_#{predicate}", value
              splitter.split_key predicate.to_sym
              send splitter.op, splitter.field, splitter.value, entity_type
            end
          end

          def predicates_for(*attributes)
            attributes.each do |attribute|
              PREDICATES.each { |predicate| predicate_filter(attribute, predicate) }
            end
          end
        end
      end
    end
  end
end
