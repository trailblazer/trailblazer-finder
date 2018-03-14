module Trailblazer
  class Finder
    module Filter
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def filter_by(name, options = nil, &block)
          return super unless options.is_a?(Hash) && options[:defined_by]

          raise Error::BlockIgnored if block
          raise Error::WithIgnored if options[:with]

          handler = Handler.build(name, options[:defined_by])

          super(name, options, &handler)
        end
      end

      module Handler
        module_function

        def build(name, defined_bys) 
          defined_bys = defined_bys.map(&:to_s)
          handler = self
          lambda do |entity_type, value|
            handler.apply_filter(
              object: self,
              filter_by: name,
              defined_bys: defined_bys,
              entity_type: entity_type,
              value: value
            )
          end
        end

        def apply_filter(object:, filter_by:, defined_bys:, entity_type:, value:) 
          return if value.nil? || value == ''

          unless defined_bys.include? value
            return handle_invalid_value(
              object: object,
              filter_by: filter_by,
              defined_bys: defined_bys,
              entity_type: entity_type,
              value: value
            )
          end

          object.send("apply_#{filter_by}_with_#{Utils::String.underscore(value)}", entity_type)
        end

        def handle_invalid_value(object:, filter_by:, defined_bys:, entity_type:, value:)
          specific = "handle_invalid_#{filter_by}"
          return object.send(specific, entity_type, value) if object.respond_to? specific, true

          catch_all = 'handle_invalid_defined_by'
          return object.send(catch_all, filter_by, entity_type, value) if object.respond_to? catch_all, true

          raise Error::InvalidDefinedByValue.new(filter_by, defined_bys, value)
        end
      end
    end
  end
end
