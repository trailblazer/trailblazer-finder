module Trailblazer
  class Finder
    class Find
      attr_reader :params

      def initialize(entity_type, params, actions)
        @entity_type  = entity_type
        @actions      = actions
        @params       = params
      end

      def param(name)
        @params[name]
      end

      def query(context)
        @params.inject(@entity_type) do |entity_type, (name, value)|
          new_entity_type = context.instance_exec entity_type, value, &@actions[name]
          new_entity_type || entity_type
        end
      end

      def count(context)
        query(context).count
      end
    end
  end
end
