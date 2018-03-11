if Gem.loaded_specs.key?('activerecord')
  module Trailblazer
    class Finder
      module Adapters
        # FriendlyId Adapter
        module FriendlyId
          def self.included(base)
            base.extend ClassMethods
            base.class_eval do
              filter_by :id, with: :apply_slug_filter
            end
          end

          def apply_slug_filter(entity_type, value)
            return if value.nil?
            return if value == ''
            if num?(value)
              entity_type.where(id: value)
            else
              entity_type.where(slug: Utils::String.underscore(value.downcase))
            end
          end

          def num?(str)
            Integer(str)
          rescue ArgumentError, TypeError
            false
          end
        end
      end
    end
  end
end
