module Trailblazer
  class Finder
    # Base module
    module Base
      PREDICATES = %w[eq not_eq].freeze

      def self.included(base)
        base.extend ClassMethods
        base.instance_eval do
          @config = {
            defaults:  {},
            actions:   {},
            entity_type:     nil
          }
        end
      end

      def initialize(options = {})
        config      = self.class.config
        entity_type = options[:entity_type] || (config[:entity_type] && instance_eval(&config[:entity_type]))
        actions     = config[:actions] || {}
        params      = Utils::Params.normalize_params(config[:defaults], options[:filter], actions.keys)

        raise Error::MissingEntityType unless entity_type

        @find = Find.new(entity_type, params, actions)
      end

      def results
        @results ||= fetch_results
      end

      def results?
        results.any?
      end

      def count
        @count ||= @find.count self
      end

      def params(additions = {})
        if additions.empty?
          @find.params
        else
          @find.params.merge Utils::Params.stringify_keys(additions)
        end
      end

      private

      def fetch_results
        @find.query self
      end

      # ClassMethods
      module ClassMethods
        attr_reader :config

        def inherited(base)
          base.instance_variable_set '@config', Utils::Extra.deep_copy(config)
        end

        def entity_type(&block)
          config[:entity_type] = block
        end

        def filter_by(name, options = nil, &block)
          options = { default: options } unless options.is_a?(Hash)

          name    = name.to_s
          default = options[:default]
          handler = options[:with] || block

          config[:defaults][name] = default unless default.nil?
          config[:actions][name]  = normalize_find_handler(handler, name)

          define_method(name) { @find.param name }
        end

        def results(*args)
          new(*args).results
        end

        def normalize_find_handler(handler, key)
          case handler
          when Symbol then ->(entity_type, value) { method(handler).call entity_type, value }
          when Proc then handler
          else
            lambda do |entity_type, value|
              return if Utils::String.blank?(value)
              Utils::DeepLocate.deep_locate ->(k, v, _object) { k == key.to_sym && v == value }, entity_type
            end
          end
        end
      end
    end
  end
end
