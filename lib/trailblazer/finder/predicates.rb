module Trailblazer
  class Finder
    module Predicates
      def not_eq(attribute, value, entity_type)
        return if Utils::String.blank?(value.to_s)
        Utils::DeepLocate.deep_locate ->(k, v, _object) { k == attribute.to_sym && v.to_s != value.to_s && v != nil }, entity_type
      end

      def eq(attribute, value, entity_type)
        return if Utils::String.blank?(value.to_s)
        Utils::DeepLocate.deep_locate ->(k, v, _object) { k == attribute.to_sym && v.to_s == value.to_s && v != nil }, entity_type
      end

      def blank(attribute, _value, entity_type)
        Utils::DeepLocate.deep_locate ->(k, v, _object) { k == attribute.to_sym && Utils::String.blank?(v.to_s) }, entity_type
      end

      def not_blank(attribute, _value, entity_type)
        Utils::DeepLocate.deep_locate ->(k, v, _object) { k == attribute.to_sym && !Utils::String.blank?(v.to_s) }, entity_type
      end

      def gt(attribute, value, entity_type)
        Utils::DeepLocate.deep_locate ->(k, v, _object) { k == attribute.to_sym && v.to_i > value.to_f }, entity_type
      end

      def gte(attribute, value, entity_type)
        Utils::DeepLocate.deep_locate ->(k, v, _object) { k == attribute.to_sym && v.to_i >= value.to_f }, entity_type
      end

      def lt(attribute, value, entity_type)
        Utils::DeepLocate.deep_locate ->(k, v, _object) { k == attribute.to_sym && v.to_i < value.to_f }, entity_type
      end

      def lte(attribute, value, entity_type)
        Utils::DeepLocate.deep_locate ->(k, v, _object) { k == attribute.to_sym && v.to_i <= value.to_f }, entity_type
      end
    end
  end
end
